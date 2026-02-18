import Foundation
import ManualSModels

extension Interpolation.Cooling.Request {
  func respond(
    houseLoad: CoolingCapacity,
    outdoorDesignTemperature: Double,
    manufacturersAdjustments: CoolingCapacityAdjustment?
  ) async -> Interpolation.Cooling.Response {
    switch self {
    case .noInterpolation(let request):
      return await request.respond(
        houseLoad: houseLoad,
        manufacturersAdjustments: manufacturersAdjustments
      )
    case .oneWayIndoor(let request):
      return await .init(
        interpolatedCapacity: request.rawValue.indoorInterpolatedCapacity(),
        houseLoad: houseLoad,
        manufacturersAdjustments: manufacturersAdjustments
      )
    case .oneWayOutdoor(let request):
      let interpolatedCapacity = await request.rawValue.outdoorInterpolatedCapacity(
        outdoorDesignTemperature: outdoorDesignTemperature
      )
      return await .init(
        interpolatedCapacity: interpolatedCapacity,
        houseLoad: houseLoad,
        manufacturersAdjustments: manufacturersAdjustments
      )
    case .twoWay(let request):
      let aboveIndoor = await request.aboveDesign.oneWayIndoorRequest.indoorInterpolatedCapacity()
      let belowIndoor = await request.belowDesign.oneWayIndoorRequest.indoorInterpolatedCapacity()
      let oneWayOutdoor = request.oneWayOutdoorRequest(above: aboveIndoor, below: belowIndoor)
      let interpolatedCapacity = await oneWayOutdoor.outdoorInterpolatedCapacity(
        outdoorDesignTemperature: outdoorDesignTemperature
      )

      return await .init(
        interpolatedCapacity: interpolatedCapacity,
        houseLoad: houseLoad,
        manufacturersAdjustments: manufacturersAdjustments
      )

    }
  }
}

extension Interpolation.Cooling.Request.NoInterpolation {
  func respond(
    houseLoad: CoolingCapacity,
    manufacturersAdjustments: CoolingCapacityAdjustment?
  ) async -> Interpolation.Cooling.Response {
    await .init(
      interpolatedCapacity: capacity.capacity,
      houseLoad: houseLoad,
      manufacturersAdjustments: manufacturersAdjustments
    )
  }
}

extension Interpolation.Cooling.Response {

  init(
    interpolatedCapacity: CoolingCapacity,
    houseLoad: CoolingCapacity,
    manufacturersAdjustments: CoolingCapacityAdjustment?
  ) async {

    let excessLatent = (interpolatedCapacity.latent - houseLoad.latent) / 2
    var finalCapacity = interpolatedCapacity.adjust(excessLatent: excessLatent)
    if let manufacturersAdjustments {
      finalCapacity = finalCapacity.apply(manufacturersAdjustments)
    }

    self.init(
      interpolatedCapacity: interpolatedCapacity,
      excessLatent: Int(excessLatent),
      finalCapacityAtyDesign: finalCapacity,
      capacityAsPercentOfLoad: houseLoad.capacityAsPercentOfLoad(finalCapacity)
    )
  }
}

extension Interpolation.Cooling.Request.OneWay {

  func outdoorInterpolatedCapacity(
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

  func indoorInterpolatedCapacity() async -> CoolingCapacity {
    let total =
      belowDesign.capacity.total
      + ((aboveDesign.capacity.total - belowDesign.capacity.total)
        / (aboveDesign.indoorWetBulbTemperature - belowDesign.indoorWetBulbTemperature))
      * (63 - belowDesign.indoorWetBulbTemperature)

    let sensible =
      belowDesign.capacity.sensible
      + ((aboveDesign.capacity.sensible - belowDesign.capacity.sensible)
        / (belowDesign.capacity.total - aboveDesign.capacity.total))
      * (belowDesign.capacity.total - total)

    return .init(total: total, sensible: sensible)
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
}

extension CoolingCapacity {
  func adjust(excessLatent: Double) -> Self {
    .init(total: rawValue.total, sensible: rawValue.sensible + excessLatent)
  }

  func apply(_ adjustments: CoolingCapacityAdjustment) -> Self {
    .init(
      total: rawValue.total * adjustments.total.decimal,
      sensible: rawValue.sensible * adjustments.sensible.decimal
    )
  }

  func capacityAsPercentOfLoad(_ finalCapacity: Self)
    -> Interpolation.Cooling.Response.CapacityAsPercentOfLoad
  {
    .init(
      total: .init(decimal: finalCapacity.total / rawValue.total),
      sensible: .init(decimal: finalCapacity.sensible / rawValue.sensible),
      latent: .init(decimal: finalCapacity.latent / latent)
    )
  }
}

extension Interpolation.Cooling.Request.TwoWay.Envelope {

  var oneWayIndoorRequest: Interpolation.Cooling.Request.OneWay {
    .init(aboveDesign: aboveWetBulb, belowDesign: belowWetBulb)
  }
}

extension Interpolation.Cooling.Request.TwoWay {

  func oneWayOutdoorRequest(
    above: CoolingCapacity,
    below: CoolingCapacity
  ) -> Interpolation.Cooling.Request.OneWay {
    .init(
      aboveDesign: .init(
        cfm: self.aboveDesign.aboveWetBulb.cfm,
        indoorTemperature: self.aboveDesign.aboveWetBulb.indoorTemperature,
        indoorWetBulbTemperature: 63,
        outdoorTemperature: self.aboveDesign.aboveWetBulb.outdoorTemperature,
        capacity: above
      ),
      belowDesign: .init(
        cfm: self.belowDesign.belowWetBulb.cfm,
        indoorTemperature: self.belowDesign.belowWetBulb.indoorTemperature,
        indoorWetBulbTemperature: 63,
        outdoorTemperature: self.belowDesign.belowWetBulb.outdoorTemperature,
        capacity: below
      )
    )
  }
}
