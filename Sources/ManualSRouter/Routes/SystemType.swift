import CasePathsCore
import FoundationEssentials
import ManualSModels
import SharedModels
import Tagged
@preconcurrency import URLRouting

extension SystemType {
  // TODO: Add path for getting cooling vs. heating system types.
  public enum ViewRoute: Sendable, Routeable {
    case index
    case submit(SystemType.Create)
    case update(SystemType.ID, SystemType.Update)

    static let path = "system-type"

    public static let router = OneOf {
      Route(.case(Self.index)) {
        Path { path }
        Method.get
      }
      Route(.case(Self.submit)) {
        Path { path }
        Method.post
        Body {
          OneOf {
            FormData {
              Field("projectID") { Project.ID.parser() }
              Field("equipment") { SystemType.EquipmentType.parser() }
              Field("compressor") { SystemType.CompressorType.parser() }
              Field("climate") { SystemType.ClimateType.parser() }
            }
            .map(.memberwise(SystemType.Create.init(projectID:equipment:compressor:climate:)))

            FormData {
              Field("projectID") { Project.ID.parser() }
              Field("heating") { SystemType.Heating.parser() }
            }
            .map(.memberwise(SystemType.Create.init(projectID:heating:)))
          }
        }
      }
      Route(.case(Self.update)) {
        Path {
          path
          SystemType.ID.parser()
        }
        Method.patch
        Body {
          OneOf {
            FormData {
              Field("equipment") { SystemType.EquipmentType.parser() }
              Field("compressor") { SystemType.CompressorType.parser() }
              Field("climate") { SystemType.ClimateType.parser() }
            }
            .map(.memberwise(SystemType.Update.init(equipment:compressor:climate:)))

            FormData {
              Field("heating") { SystemType.Heating.parser() }
            }
            .map(.memberwise(SystemType.Update.init(heating:)))
          }
        }
      }

    }
  }
}

extension SystemType.Create {
  init(
    projectID: Project.ID,
    equipment: SystemType.EquipmentType,
    compressor: SystemType.CompressorType,
    climate: SystemType.ClimateType
  ) {
    self.init(
      projectID: projectID,
      cooling: .init(equipment: equipment, compressor: compressor, climate: climate)
    )
  }

  init(projectID: Project.ID, heating: SystemType.Heating) {
    self.init(projectID: projectID, cooling: nil, heating: heating)
  }
}

extension SystemType.Update {
  init(
    equipment: SystemType.EquipmentType,
    compressor: SystemType.CompressorType,
    climate: SystemType.ClimateType
  ) {
    self.init(
      cooling: .init(equipment: equipment, compressor: compressor, climate: climate), heating: nil)
  }

  init(heating: SystemType.Heating) {
    self.init(cooling: nil, heating: heating)
  }
}
