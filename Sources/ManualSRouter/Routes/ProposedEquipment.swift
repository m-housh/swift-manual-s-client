import CasePathsCore
import FoundationEssentials
import ManualSModels
import SharedModels
import Tagged
@preconcurrency import URLRouting
import Validations

extension ProposedEquipment {
  public enum ViewRoute: Equatable, Sendable, Routeable {
    case index
    case submit(ProposedEquipment.FormIntermediate)
    case update(ProposedEquipment.ID, ProposedEquipment.FormIntermediate)

    static let path = "proposed-equipment"

    public static let router = OneOf {
      Route(.case(Self.index)) {
        Path { path }
        Method.get
      }
      Route(.case(Self.submit)) {
        Path { path }
        Method.post
        Body {
          ProposedEquipment.FormIntermediate.parser
        }
      }
      Route(.case(Self.update)) {
        Path {
          path
          ProposedEquipment.ID.parser()
        }
        Method.patch
        Body {
          ProposedEquipment.FormIntermediate.parser
        }
      }
    }
  }

  public struct FormIntermediate: Equatable, Sendable {

    let projectID: Project.ID?
    let afue: Percent?
    let seer: Double?
    let hspf: Double?
    let fanSpeed: ProposedEquipment.FanSpeed?
    let equipmentManufacturers: [String]
    let equipmentModels: [String]
    let equipmentTypes: [ProposedEquipment.EquipmentType]

    public init(
      projectID: Project.ID? = nil,
      afue: Percent? = nil,
      seer: Double? = nil,
      hspf: Double? = nil,
      fanSpeed: ProposedEquipment.FanSpeed? = nil,
      equipmentManufacturers: [String],
      equipmentModels: [String],
      equipmentTypes: [ProposedEquipment.EquipmentType]
    ) {
      self.projectID = projectID
      self.afue = afue
      self.seer = seer
      self.hspf = hspf
      self.fanSpeed = fanSpeed
      self.equipmentManufacturers = equipmentManufacturers
      self.equipmentModels = equipmentModels
      self.equipmentTypes = equipmentTypes
    }
  }
}

extension ProposedEquipment.FormIntermediate {

  static let parser = FormData {
    Optionally {
      Field("projectID") { Project.ID.parser() }
    }
    Optionally {
      Field("afue") { Percent.parser() }
    }
    Optionally {
      Field("seer") { Double.parser() }
    }
    Optionally {
      Field("hspf") { Double.parser() }
    }
    Optionally {
      Field("fanSpeed") { ProposedEquipment.FanSpeed.parser() }
    }
    Many {
      Field("equipment[manufacturer]", .string)
    }
    Many {
      Field("equipment[model]", .string)
    }
    Many {
      Field("equipment[type]") { ProposedEquipment.EquipmentType.parser() }
    }
  }
  .map(.memberwise(ProposedEquipment.FormIntermediate.init))

  private static var createValidator: some Validation<ProposedEquipment.FormIntermediate> {
    Validator.accumulating {
      Validator.validate(\.projectID, with: .notNil())
      Validator.equals(\.equipmentManufacturers.count, \.equipmentModels.count)
      Validator.equals(\.equipmentManufacturers.count, \.equipmentTypes.count)
    }
  }

  private static var updateValidator: some Validation<ProposedEquipment.FormIntermediate> {
    Validator.accumulating {
      Validator.equals(\.equipmentManufacturers.count, \.equipmentModels.count)
      Validator.equals(\.equipmentManufacturers.count, \.equipmentTypes.count)
    }
  }

  private var equipment: [ProposedEquipment.Equipment] {
    var out = [ProposedEquipment.Equipment]()
    for (index, manufacturer) in equipmentManufacturers.enumerated() {
      out.append(
        .init(
          manufacturer: manufacturer,
          model: equipmentModels[index],
          equipmentType: equipmentTypes[index]
        )
      )
    }
    return out
  }

  public func toCreate() throws -> ProposedEquipment.Create {
    try Self.createValidator.validate(self)
    return .init(
      projectID: projectID!,
      afue: afue,
      seer: seer,
      hspf: hspf,
      fanSpeed: fanSpeed,
      equipment: equipment
    )
  }

  public func toUpdate() throws -> ProposedEquipment.Update {
    try Self.updateValidator.validate(self)
    return .init(
      afue: afue,
      seer: seer,
      hspf: hspf,
      fanSpeed: fanSpeed,
      equipment: equipment
    )
  }

}
