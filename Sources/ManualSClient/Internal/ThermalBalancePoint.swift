import Foundation

extension ManualSClient.ThermalBalancePointRequest {

  func respond() async throws -> Double {
    (30.0 * (((outdoorDesignTemperature - 65.0) * capacity.capacityAt47) + (65.0 * heatLoss))
      - ((outdoorDesignTemperature - 65.0) * (capacity.capacityAt47 - capacity.capacityAt17) * 47.0))
      / ((30.0 * heatLoss)
        - ((outdoorDesignTemperature - 65.0) * (capacity.capacityAt47 - capacity.capacityAt17)))
  }
}
