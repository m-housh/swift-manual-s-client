import Elementary
import ElementaryHTMX
import ManualSModels
import ManualSRouter
import SharedStyleguide

struct BoilerOrFurnaceForm: HTML, Identifiable, Sendable {

  static let id = "boilerOrFurnaceForm"

  var id: String { Self.id }
  let projectID: Project.ID
  let interpolation: HeatingInterpolation?

  private var route: String {
    ManualSRoute.router.path(for: .projectDetail(projectID, .interpolations(.heating(.index))))
      .appendingPath(interpolation?.id)
  }

  var body: some HTML<HTMLTag.form> {
    Form(
      title: "Gas - Heating",
      interpolation == nil
        ? .hx.post(route)
        : .hx.patch(route),
      .hx.target(id: ProjectDetailsView.Section.id(.heatingInterpolation())),
      .hx.swap(.outerHTML)
    ) {

      input(.hidden, .name("projectID"), .value(projectID))

      if let interpolation {
        input(.hidden, .name("id"), .value(interpolation.id))
      }

      Fieldset("Input") {
        label(.class("input w-full")) {
          span(.class("label")) { SVG(.flame) }
          input(
            .type(.number),
            .name("inputBTU"),
            .value(interpolation?.boilerOrFurnace?.inputBTU),
            .min(0),
            .step(1),
            .required
          )
          span(.class("label")) { "BTU/h" }
        }
      }

      Fieldset("Equipment Type") {
        label(.class("select w-full")) {
          span(.class("label")) { "Type" }
          Select(
            HeatingInterpolation.Interpolation.BoilerOrFurnace.BoilerOrFurnaceType.allCases,
            value: \.rawValue,
            selected: {
              interpolation == nil
                ? $0 == .furnace
                : $0 == interpolation?.boilerOrFurnace?.type
            },
            label: \.title
          )
          .attributes(
            .name("type"),
            .required
          )
        }
      }

      SubmitButton()
        .attributes(.class("btn-block mt-6"))
    }
  }

}

extension HeatingInterpolation.Interpolation.BoilerOrFurnace.BoilerOrFurnaceType {
  var title: String { rawValue.capitalized }
}
