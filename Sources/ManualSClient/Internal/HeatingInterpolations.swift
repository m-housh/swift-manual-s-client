import Foundation
import ManualSModels

extension HeatingInterpolation.Request.Electric {
  func respond() async -> HeatingInterpolation.Response.Electric {
    let requiredKW = await calculateRequiredKW(
      heatLoss: Double(heatingLoad), capacityAtDesign: 0
    )

    return .init(
      requiredKW: requiredKW,
      percentOfLoad: .init(decimal: Double(kilowatts) / requiredKW),
      sizingLimits: SystemType.Heating.electric.sizingLimit
    )
  }
}

extension HeatingInterpolation.Request.FurnaceOrBoiler {

  func respond() async -> HeatingInterpolation.Response.GasOrBoiler {
    let output = Double(inputBTU) * afue.decimal
    let altitudeDerating = await SystemType.Heating.furnace.derating(
      elevation: Double(projectElevation)
    )
    let finalCapacity = output * altitudeDerating

    return .init(
      altitudeDerating: .init(decimal: altitudeDerating),
      outputCapacity: Int(output),
      finalCapacity: Int(finalCapacity),
      percentOfLoad: .init(decimal: finalCapacity / Double(heatingLoad)),
      sizingLimits: SystemType.Heating.furnace.sizingLimit
    )
  }
}

extension HeatingInterpolation.Request.HeatPump {

  func respond() async throws -> HeatingInterpolation.Response.HeatPump {
    let altitudeDerating = await Percent(
      decimal: SystemType.Heating.heatPump.derating(elevation: Double(projectElevation))
    )

    let balancePoint = try await ManualSClient.ThermalBalancePointRequest(
      capacity: capacity,
      heatLoss: Double(heatingLoad),
      outdoorDesignTemperature: Double(outdoorDesignTemperature)
    ).respond()

    let capacityAtDesign = await capacity.capacity(at: Double(outdoorDesignTemperature))
    let requiredKW = await calculateRequiredKW(
      heatLoss: Double(heatingLoad),
      capacityAtDesign: capacityAtDesign
    )

    return await .init(
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
