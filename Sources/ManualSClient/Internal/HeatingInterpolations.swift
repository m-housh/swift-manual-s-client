import Foundation
import ManualSModels

extension HeatingInterpolation.Response.Electric {

  init(
    inputKW: Double,
    heatLoss: Double
  ) async {
    let requiredKW = await calculateRequiredKW(
      heatLoss: heatLoss, capacityAtDesign: 0
    )

    self.init(
      requiredKW: requiredKW,
      percentOfLoad: .init(decimal: inputKW / requiredKW),
      sizingLimits: SystemType.Heating.electric.sizingLimit
    )
  }
}

extension HeatingInterpolation.Response.GasOrBoiler {

  init(
    input: Double,
    afue: Percent,
    elevation: Double,
    heatLoss: Double
  ) async throws {
    let output = input * afue.decimal
    let altitudeDerating = await SystemType.Heating.furnace.derating(elevation: elevation)
    let finalCapacity = output * altitudeDerating

    self.init(
      altitudeDerating: .init(decimal: altitudeDerating),
      outputCapacity: Int(output),
      finalCapacity: Int(finalCapacity),
      percentOfLoad: .init(decimal: finalCapacity / heatLoss),
      sizingLimits: SystemType.Heating.furnace.sizingLimit
    )
  }
}

extension HeatingInterpolation.Response.HeatPump {
  init(
    capacity: HeatPumpCapacity,
    heatLoss: Double,
    elevation: Double,
    outdoorTemperature: Double
  ) async throws {

    let altitudeDerating = await Percent(
      decimal: SystemType.Heating.heatPump.derating(elevation: elevation)
    )

    let balancePoint = try await ManualSClient.ThermalBalancePointRequest(
      capacity: capacity, heatLoss: heatLoss, outdoorDesignTemperature: outdoorTemperature
    ).respond()

    let capacityAtDesign = await capacity.capacity(at: outdoorTemperature)
    let requiredKW = await calculateRequiredKW(
      heatLoss: heatLoss, capacityAtDesign: capacityAtDesign)

    await self.init(
      deratings: altitudeDerating,
      finalCapacity: capacity.derate(altitudeDerating),
      capacityAtDesign: capacityAtDesign,
      balancePointTemperature: balancePoint,
      requiredKW: requiredKW
    )
  }
}

extension HeatPumpCapacity {

  fileprivate func derate(_ derating: Percent) async -> Self {
    .init(
      capacityAt47: capacityAt47 * derating.decimal,
      capacityAt17: capacityAt17 * derating.decimal
    )
  }

  fileprivate func capacity(at outdoorTemperature: Double) async -> Double {
    let x = (capacityAt47 - capacityAt17) / 30
    let y = 17 - outdoorTemperature
    let z = x * y
    return (capacityAt17 - z)
  }
}
