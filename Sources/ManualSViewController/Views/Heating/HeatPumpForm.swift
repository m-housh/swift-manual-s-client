import Elementary
import ElementaryHTMX
import Foundation
import ManualSModels
import ManualSRouter
import SharedStyleguide

struct HeatPumpForm: HTML, Identifiable, Sendable {

  static let id = "heatPumpHeatingForm"

  let projectID: Project.ID
  let interpolation: HeatingInterpolation?

  var id: String { Self.id }

  private var route: String {
    ManualSRoute.router.path(for: .projectDetail(projectID, .interpolations(.heating(.index))))
      .appendingPath(interpolation?.id)
  }

  var body: some HTML<HTMLTag.form> {
    Form(
      title: "Heating - Heat Pump",
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

      Fieldset("Output") {
        label(.class("input w-full")) {
          span(.class("label")) { "@ 47°" }
          input(
            .type(.number),
            .name("capacityAt47"),
            .value(interpolation?.heatPump?.capacityAt47),
            .min(0),
            .step(1),
            .required
          )
        }

        label(.class("input w-full")) {
          span(.class("label")) { "@ 17°" }
          input(
            .type(.number),
            .name("capacityAt17"),
            .value(interpolation?.heatPump?.capacityAt17),
            .min(0),
            .step(1),
            .required
          )
        }
      }

      SubmitButton()
        .attributes(.class("btn-block"))
    }
  }
}

