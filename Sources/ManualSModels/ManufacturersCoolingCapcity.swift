/// Represent manufacturer's data about the cooling capacity of a unit.
///
public struct ManufacturersCoolingCapacity: Codable, Equatable, Sendable {

  /// The rated CFM for the unit.
  public let cfm: Int

  /// The rated indoor temperature for the unit.
  public let indoorTemperature: Int

  /// The rated indoor wet-bulb temperature for the unit.
  public let indoorWetBulbTemperature: Double

  /// The rated outdoor temperature for the unit.
  public let outdoorTemperature: Int

  /// The rated cooling capacity of the unit.
  public let capacity: CoolingCapacity

  public init(
    cfm: Int,
    indoorTemperature: Int,
    indoorWetBulbTemperature: Double,
    outdoorTemperature: Int,
    capacity: CoolingCapacity
  ) {
    self.cfm = cfm
    self.indoorTemperature = indoorTemperature
    self.indoorWetBulbTemperature = indoorWetBulbTemperature
    self.outdoorTemperature = outdoorTemperature
    self.capacity = capacity
  }
}
