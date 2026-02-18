public struct HeatPumpCapacity: Codable, Equatable, Sendable {

  public let capacityAt47: Double
  public let capacityAt17: Double

  public init(capacityAt47: Double, capacityAt17: Double) {
    self.capacityAt47 = capacityAt47
    self.capacityAt17 = capacityAt17
  }
}
