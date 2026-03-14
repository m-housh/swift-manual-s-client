import CasePathsCore
import Elementary
import ElementaryHTMX
import ManualSModels
import ManualSRouter
import SharedModels
import SharedStyleguide

struct NoInterpolationForm: HTML, Identifiable, Sendable {

  static let id = "noInterpolationForm"
  var id: String { Self.id }
  let projectID: Project.ID
  let interpolation: CoolingInterpolation?

  private var route: String {
    ManualSRoute.router.path(for: .projectDetail(projectID, .interpolations(.cooling(.index))))
      .appendingPath(interpolation?.id)
  }

  var body: some HTML<HTMLTag.form> {
    Form(
      title: "No Interpolation",
      interpolation == nil
        ? .hx.post(route)
        : .hx.patch(route),
      .hx.target(id: ProjectDetailsView.Section.id(.coolingInterpolation())),
      .hx.swap(.outerHTML)
    ) {

      input(.hidden, .name("projectID"), .value(projectID))

      DesignAirflowFieldset(designAirflow: interpolation?.designAirflow)

      TotalSensibleFieldset(.coolingCapacity(interpolation?.noInterpolation))

      TotalSensibleFieldset(.manufacturersAdjustments(interpolation?.manufacturersAdjustments))

      SubmitButton()
        .attributes(.class("btn-block"))
    }
  }
}
