import Dependencies
import Foundation
import Tagged

public struct ProposedEquipment: Codable, Equatable, Identifiable, Sendable {

  public let id: Tagged<Self, UUID>
  public let afue: Percent?
  public let seer: Double?
  public let hspf: Double?
  public let fanSpeed: FanSpeed?
  public let equipment: [Equipment]

  public struct Equipment: Codable, Equatable, Sendable {
    public let manufacturer: String
    public let model: String
    public let equipmentType: EquipmentType

    public init(
      manufacturer: String,
      model: String,
      equipmentType: ProposedEquipment.EquipmentType
    ) {
      self.manufacturer = manufacturer
      self.model = model
      self.equipmentType = equipmentType
    }

  }

  public enum EquipmentType: String, CaseIterable, Codable, Sendable {
    case airConditioner
    case airHandler
    case evaportorCoil
    case heatPump
    case furnace
    case packaged

    public var label: String {
      switch self {
      case .airConditioner: return "Air Conditioner"
      case .airHandler: return "Air Handler"
      case .evaportorCoil: return "Evaporator Coil"
      case .heatPump: return "Heat Pump"
      case .furnace, .packaged: return rawValue.capitalized
      }
    }
  }

  public enum FanSpeed: String, CaseIterable, Codable, Sendable {
    case low
    case medium
    case mediumHigh
    case high

    public var label: String {
      switch self {
      case .low, .medium, .high: return rawValue.capitalized
      case .mediumHigh: return "Medium-High"
      }
    }
  }
}

#if DEBUG
  extension ProposedEquipment {
    public static var mock: Self {
      @Dependency(\.uuid) var uuid
      return .init(
        id: .init(uuid()),
        afue: 98,
        seer: 18.2,
        hspf: 9.5,
        fanSpeed: .mediumHigh,
        equipment: [
          .init(manufacturer: "Tempstar", model: "FVME060", equipmentType: .furnace),
          .init(manufacturer: "Bosch", model: "BMAC024", equipmentType: .evaportorCoil),
          .init(manufacturer: "Bosch", model: "BOVA024", equipmentType: .heatPump),
        ]
      )
    }
  }
#endif
