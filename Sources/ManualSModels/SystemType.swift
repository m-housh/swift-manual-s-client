import Foundation
import SharedModels
import Tagged

public struct SystemType: Codable, Equatable, Identifiable, Sendable {

  public let id: Tagged<Self, UUID>
  public let projectID: Project.ID
  public let cooling: Cooling?
  public let heating: Heating?
  public let createdAt: Date
  public let updatedAt: Date

  public init(
    id: Tagged<SystemType, UUID>,
    projectID: Project.ID,
    cooling: SystemType.Cooling? = nil,
    heating: SystemType.Heating? = nil,
    createdAt: Date,
    updatedAt: Date
  ) {
    self.id = id
    self.projectID = projectID
    self.cooling = cooling
    self.heating = heating
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }

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

    public var labels: [String] {
      Array(label.split(separator: "or").map(String.init))
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

extension SystemType {
  public struct Create: Codable, Equatable, Sendable {

    public let projectID: Project.ID
    public let cooling: SystemType.Cooling?
    public let heating: SystemType.Heating?

    public init(
      projectID: Project.ID,
      cooling: SystemType.Cooling? = nil,
      heating: SystemType.Heating? = nil
    ) {
      self.projectID = projectID
      self.cooling = cooling
      self.heating = heating
    }
  }

  public struct Update: Codable, Equatable, Sendable {

    public let cooling: SystemType.Cooling?
    public let heating: SystemType.Heating?

    public init(
      cooling: SystemType.Cooling? = nil,
      heating: SystemType.Heating? = nil
    ) {
      self.cooling = cooling
      self.heating = heating
    }
  }
}

#if DEBUG
  extension SystemType.Cooling {
    public static let mock = Self(
      equipment: .heatPump,
      compressor: .variableSpeed,
      climate: .mildWinterOrLatentLoad
    )
  }
#endif
