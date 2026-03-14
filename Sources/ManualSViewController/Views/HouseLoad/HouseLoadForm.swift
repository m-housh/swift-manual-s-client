import Elementary
import ElementaryHTMX
import ManualSModels
import ManualSRouter
import SharedModels
import SharedStyleguide

struct HouseLoadForm: HTML, Identifiable, Sendable {
  static let id = "houseLoadForm"

  let projectID: Project.ID
  let houseLoad: HouseLoad?
  var id: String { Self.id }

  var route: String {
    ManualSRoute.router.path(for: .projectDetail(projectID, .houseLoads(.index)))
      .appendingPath(houseLoad?.id)
  }

  var body: some HTML<HTMLTag.form> {
    Form(
      title: "House Load",
      .class("space-y-4"),
      houseLoad == nil
        ? .hx.post(route)
        : .hx.patch(route),
      .hx.target(id: ProjectDetailsView.Section.id(.houseLoad())),
      .hx.swap(.outerHTML)
    ) {

      if let houseLoad {
        input(.hidden, .name("id"), .value(houseLoad.id))
      }

      input(.hidden, .name("projectID"), .value(projectID))

      Fieldset("Heating") {
        label(.class("input w-full")) {
          span(.class("label")) { SVG(.flame) }
          input(
            .type(.number),
            .name("heating"),
            .value(houseLoad?.heating),
            .min(0),
            .step(1),
            .required
          )
        }
      }

      TotalSensibleFieldset(.coolingLoad(houseLoad?.cooling))
        .fieldsetContentStyle(.vstack())

      SubmitButton()
        .attributes(.class("btn-block mt-6"))
    }
  }
}
