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
  let interpolationID: CoolingInterpolation.ID?
  let capacity: CoolingCapacity?

  var route: String {
    ManualSRoute.router.path(for: .projectDetail(projectID, .interpolations(.cooling(.index))))
      .appendingPath(interpolationID)
  }

  var body: some HTML<HTMLTag.form> {
    Form(
      title: "No Interpolation",
      interpolationID == nil
        ? .hx.post(route)
        : .hx.patch(route),
      .hx.target(id: ProjectDetailsView.Section.id(.coolingInterpolation())),
      .hx.swap(.outerHTML)
    ) {

      input(.hidden, .name("projectID"), .value(projectID))

      CoolingCapacityFieldset(capacity: capacity)
      ManufacturersAdjustmentFieldset(adjustments: nil)

      SubmitButton()
        .attributes(.class("btn-block"))
    }
  }
}
