import Elementary
import ManualSModels
import ManualSRouter
import SharedModels
import SharedStyleguide

struct CoolingSystemTypeForm: HTML, Identifiable, Sendable {
  static let id = "coolingSystemTypeForm"

  let projectID: Project.ID
  let systemTypeID: SystemType.ID?
  let systemType: SystemType.Cooling?
  var id: String { Self.id }

  var route: String {
    ManualSRoute.router.path(for: .projectDetail(projectID, .systemTypes(.index)))
      .appendingPath(systemTypeID)
  }

  var body: some HTML<HTMLTag.form> {
    Form(
      title: "System Type",
      systemTypeID == nil
        ? .hx.post(route)
        : .hx.patch(route),
      .hx.target(id: ProjectDetailsView._Section.id(.coolingSystemType())),
      .hx.swap(.outerHTML)
    ) {

      input(.hidden, .name("projectID"), .value(projectID))

      fieldset(.class("fieldset")) {
        legend(.class("fieldset-legend")) { "Type" }
        Select(
          SystemType.EquipmentType.allCases,
          value: \.rawValue,
          selected: {
            guard let systemType else {
              return $0 == .airConditioner
            }
            return systemType.equipment == $0
          },
          label: \.label
        )
        .attributes(
          .class("select w-full"),
          .id("equipment"),
          .name("equipment"),
          .required
        )
      }

      fieldset(.class("fieldset")) {
        legend(.class("fieldset-legend")) { "Compressor" }
        Select(
          SystemType.CompressorType.allCases,
          value: \.rawValue,
          selected: {
            guard let systemType else {
              return $0 == .singleSpeed
            }
            return systemType.compressor == $0
          },
          label: \.label
        )
        .attributes(
          .class("select w-full"),
          .name("compressor"),
          .id("compressor"),
          .required
        )
      }

      fieldset(.class("fieldset")) {
        legend(.class("fieldset-legend")) { "Climate" }
        Select(
          SystemType.ClimateType.allCases,
          value: \.rawValue,
          selected: {
            guard let systemType else {
              return $0 == .mildWinterOrLatentLoad
            }
            return systemType.climate == $0
          },
          label: \.label
        )
        .attributes(
          .class("select w-full"),
          .id("climate"),
          .name("climate"),
          .required
        )
      }

      SubmitButton()
        .attributes(.class("btn-block"))
    }
  }
}
