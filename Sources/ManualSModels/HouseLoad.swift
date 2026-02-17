public struct HouseLoad: Codable, Equatable, Sendable {

  public let heating: Double
  public let cooling: CoolingCapcity

  public init(heating: Double, cooling: CoolingCapcity) {
    self.heating = heating
    self.cooling = cooling
  }
}
