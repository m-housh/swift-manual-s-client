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

    public var label: String {
      "\(equipment.label), \(compressor.label), \(climate.label)"
    }
  }

  public enum Heating: String, CaseIterable, Codable, Equatable, Sendable {
    case boiler
    case electric
    case furnace
    case heatPump

    public var label: String {
      switch self {
      case .boiler, .electric, .furnace:
        return rawValue.capitalized
      case .heatPump:
        return "Heat Pump"
      }
    }
  }

  public enum ClimateType: String, CaseIterable, Codable, Equatable, Sendable {
    case mildWinterOrLatentLoad
    case coldWinterOrNoLatentLoad

    public var label: String {
      switch self {
      case .mildWinterOrLatentLoad:
        return "Mild Winter or Latent Load"
      case .coldWinterOrNoLatentLoad:
        return "Cold Winter or No Latent Load"
      }
    }
  }

  public enum CompressorType: String, CaseIterable, Codable, Equatable, Sendable {
    case singleSpeed
    case multiSpeed
    case variableSpeed

    public var label: String {
      switch self {
      case .singleSpeed:
        return "Single Speed"
      case .multiSpeed:
        return "Multi Speed"
      case .variableSpeed:
        return "Variable Speed"
      }
    }
  }

  public enum EquipmentType: String, CaseIterable, Codable, Equatable, Sendable {
    case airConditioner
    case heatPump

    public var label: String {
      switch self {
      case .airConditioner:
        return "Air Conditioner"
      case .heatPump:
        return "Heat Pump"
      }
    }
  }
}
