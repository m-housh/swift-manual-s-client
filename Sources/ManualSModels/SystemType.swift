public enum SystemType {

  public struct Cooling: Codable, Equatable, Sendable {

    public let equipment: EquipmentType
    public let compressor: CompressorType
    public let climate: ClimateType

    public init(
      equipment: SystemType.EquipmentType,
      compressor: SystemType.CompressorType,
      climate: SystemType.ClimateType
    ) {
      self.equipment = equipment
      self.compressor = compressor
      self.climate = climate
    }
  }

  public enum Heating: String, CaseIterable, Codable, Equatable, Sendable {
    case boiler
    case electric
    case furnace
    case heatPump
  }

  public enum ClimateType: String, CaseIterable, Codable, Equatable, Sendable {
    case mildWinterOrLatentLoad
    case coldWinterOrNoLatentLoad
  }

  public enum CompressorType: String, CaseIterable, Codable, Equatable, Sendable {
    case singleSpeed
    case multiSpeed
    case variableSpeed
  }

  public enum EquipmentType: String, CaseIterable, Codable, Equatable, Sendable {
    case airConditioner
    case heatPump
  }
}
