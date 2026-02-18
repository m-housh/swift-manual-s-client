public struct HouseLoad: Codable, Equatable, Sendable {

  public let heating: Double
  public let cooling: CoolingCapacity

  public init(heating: Double, cooling: CoolingCapacity) {
    self.heating = heating
    self.cooling = cooling
  }
}
