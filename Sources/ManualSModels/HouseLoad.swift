public struct HouseLoad: Codable, Equatable, Sendable {

  public let heating: Double
  public let cooling: CoolingLoad

  public init(heating: Double, cooling: CoolingLoad) {
    self.heating = heating
    self.cooling = cooling
  }
}
