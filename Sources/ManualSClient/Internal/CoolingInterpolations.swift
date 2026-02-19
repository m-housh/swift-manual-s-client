import Foundation
import ManualSModels
import Tagged

// FIX: Add altitude adjustments.
extension CoolingInterpolation.Request {
  func respond() async -> CoolingInterpolation.Response {
    switch interpolation {
    case .noInterpolation(let request):
      return await .init(
        interpolatedCapacity: request,
        request: self
      )
    case .oneWayIndoor(let request):
      return await .init(
        interpolatedCapacity: request.interpolatedCapacity(),
        request: self
      )
    case .oneWayOutdoor(let request):
      let interpolatedCapacity = await request.interpolatedCapacity(
        outdoorDesignTemperature: Double(outdoorDesignTemperature)
      )
      return await .init(
        interpolatedCapacity: interpolatedCapacity,
        request: self
      )
    case .twoWay(let request):
      async let aboveIndoor = await request.aboveDesign.oneWayIndoorRequest.interpolatedCapacity()
      async let belowIndoor = await request.belowDesign.oneWayIndoorRequest.interpolatedCapacity()
      let oneWayOutdoor = await request.oneWayOutdoorRequest(above: aboveIndoor, below: belowIndoor)
      let interpolatedCapacity = await oneWayOutdoor.interpolatedCapacity(
        outdoorDesignTemperature: Double(outdoorDesignTemperature)
      )

      return await .init(
        interpolatedCapacity: interpolatedCapacity,
        request: self
      )

    }
  }
}

extension CoolingInterpolation.Response {

  init(
    interpolatedCapacity: CoolingCapacity,
    request: CoolingInterpolation.Request
  ) async {

    let excessLatent = (interpolatedCapacity.latent - request.coolingLoad.latent) / 2
    var finalCapacity = interpolatedCapacity.adjust(excessLatent: excessLatent)
    if let manufacturersAdjustments = request.manufacturersAdjustments {
      finalCapacity = finalCapacity.apply(manufacturersAdjustments)
    }

    let altitudeDeratings = await CoolingDerating(elevation: Double(request.projectElevation))
    finalCapacity = finalCapacity.apply(altitudeDeratings)

    self.init(
      interpolatedCapacity: interpolatedCapacity,
      excessLatent: excessLatent,
      finalCapacityAtDesign: finalCapacity,
      altitudeDeratings: altitudeDeratings,
      capacityAsPercentOfLoad: request.coolingLoad.capacityAsPercentOfLoad(finalCapacity)
    )
  }
}

extension CoolingInterpolation.Request.Interpolation.OneWayOutdoor {

  func interpolatedCapacity(
    outdoorDesignTemperature: Double
  ) async -> CoolingCapacity {

    await .init(
      total: calculateOutdoor(
        outdoorDesignTemperature: outdoorDesignTemperature,
        belowCapacity: belowDesign.capacity.total,
        belowOutdoorTemperature: Double(belowDesign.outdoorTemperature),
        aboveCapacity: aboveDesign.capacity.total,
        aboveOutdoorTemperature: Double(aboveDesign.outdoorTemperature)
      ),
      sensible: calculateOutdoor(
        outdoorDesignTemperature: outdoorDesignTemperature,
        belowCapacity: belowDesign.capacity.sensible,
        belowOutdoorTemperature: Double(belowDesign.outdoorTemperature),
        aboveCapacity: aboveDesign.capacity.sensible,
        aboveOutdoorTemperature: Double(aboveDesign.outdoorTemperature)
      )
    )

  }
}

extension CoolingInterpolation.Request.Interpolation.OneWayIndoor {

  func interpolatedCapacity() async -> CoolingCapacity {
    let total =
      belowDesign.capacity.total
      + ((aboveDesign.capacity.total - belowDesign.capacity.total)
        / (Double(aboveDesign.indoorWetBulbTemperature)
          - Double(belowDesign.indoorWetBulbTemperature)))
      * (63 - Double(belowDesign.indoorWetBulbTemperature))

    let sensible =
      belowDesign.capacity.sensible
      + ((aboveDesign.capacity.sensible - belowDesign.capacity.sensible)
        / (belowDesign.capacity.total - aboveDesign.capacity.total))
      * (belowDesign.capacity.total - total)

    return .init(total: total, sensible: sensible)
  }
}

private func calculateOutdoor(
  outdoorDesignTemperature: Double,
  belowCapacity: Double,
  belowOutdoorTemperature: Double,
  aboveCapacity: Double,
  aboveOutdoorTemperature: Double
) async -> Double {
  belowCapacity
    - (outdoorDesignTemperature - belowOutdoorTemperature)
    * ((belowCapacity - aboveCapacity) / (aboveOutdoorTemperature - belowOutdoorTemperature))
}

extension CoolingCapacity {
  func adjust(excessLatent: Double) -> Self {
    .init(total: rawValue.total, sensible: rawValue.sensible + excessLatent)
  }

  func apply<N>(_ adjustments: Tagged<N, CoolingContainer<Percent>>) -> Self {
    .init(
      total: rawValue.total * adjustments.total.decimal,
      sensible: rawValue.sensible * adjustments.sensible.decimal
    )
  }
}

extension CoolingLoad {
  func capacityAsPercentOfLoad(_ finalCapacity: CoolingCapacity)
    -> CoolingInterpolation.Response.CapacityAsPercentOfLoad
  {
    .init(
      total: .init(decimal: finalCapacity.total / rawValue.total),
      sensible: .init(decimal: finalCapacity.sensible / rawValue.sensible),
      latent: .init(decimal: finalCapacity.latent / rawValue.latent)
    )
  }
}

extension CoolingInterpolation.Request.Interpolation.TwoWay.Envelope {

  var oneWayIndoorRequest: CoolingInterpolation.Request.Interpolation.OneWayIndoor {
    .init(
      aboveDesign: aboveWetBulb,
      belowDesign: belowWetBulb
    )
  }
}

extension CoolingInterpolation.Request.Interpolation.TwoWay {

  func oneWayOutdoorRequest(
    above: CoolingCapacity,
    below: CoolingCapacity
  ) -> CoolingInterpolation.Request.Interpolation.OneWayOutdoor {
    .init(
      aboveDesign: .init(
        outdoorTemperature: self.aboveDesign.outdoorTemperature,
        capacity: above
      ),
      belowDesign: .init(
        outdoorTemperature: self.belowDesign.outdoorTemperature,
        capacity: below
      )
    )
  }
}
