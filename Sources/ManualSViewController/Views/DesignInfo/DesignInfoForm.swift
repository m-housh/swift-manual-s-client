import Elementary
import ManualSModels
import ManualSRouter
import SharedModels
import SharedStyleguide

struct DesignInfoForm: HTML, Identifiable, Sendable {

  static let id = "designInfoForm"

  let projectID: Project.ID
  let designInfo: DesignInfo?
  var id: String { Self.id }

  var route: String {
    ManualSRoute.router.path(for: .projectDetail(projectID, .designInfo(.index)))
      .appendingPath(designInfo?.id)
  }

  var body: some HTML<HTMLTag.form> {
    Form(
      title: "Design Information",
      .class("space-y-4"),
      designInfo == nil
        ? .hx.post(route)
        : .hx.patch(route),
      .hx.target(id: ProjectDetailsView._Section.id(.designInfo)),
      .hx.swap(.outerHTML)
    ) {
      input(.hidden, .value(projectID), .name("projectID"))

      fieldset(.class("fieldset")) {
        legend(.class("fieldset-legend")) { "Outdoor Design - Temperature" }

        label(.class("input w-full")) {
          span(.class("label")) { SVG(.thermometerSnowflake) }
          input(
            .type(.number),
            .name("winterOutdoorTemperature"),
            .id("winterOutdoorTemperature"),
            .value(designInfo?.winterOutdoorTemperature),
            .min(0),
            .required
          )
          span(.class("label min-w-[5rem]")) { "Winter" }
        }

        label(.class("input w-full")) {
          span(.class("label")) { SVG(.thermometerSun) }
          input(
            .type(.number),
            .name("summerOutdoorTemperature"),
            .id("summerOutdoorTemperature"),
            .value(designInfo?.summerOutdoorTemperature),
            .min(0),
            .required
          )
          span(.class("label min-w-[5rem]")) { "Summer" }
        }
      }

      fieldset(.class("fieldset")) {
        legend(.class("fieldset-legend")) { "Indoor Design - Summer" }
        label(.class("input w-full")) {
          span(.class("label")) { SVG(.thermometer) }
          input(
            .type(.number),
            .name("summerIndoorTemperature"),
            .id("summerIndoorTemperature"),
            .value(designInfo?.summerIndoorTemperature ?? 75),
            .min(0),
            .required
          )
          span(.class("label min-w-[7rem]")) { "Temperature" }
        }

        label(.class("input w-full")) {
          span(.class("label")) { SVG(.droplets) }
          input(
            .type(.number),
            .name("summerIndoorHumidity"),
            .id("summerIndoorHumidity"),
            .value(designInfo?.summerIndoorHumidity.rawValue ?? 50),
            .min(0),
            .required
          )
          span(.class("label min-w-[7rem]")) { "Humidity" }
        }
      }

      fieldset(.class("fieldset")) {
        legend(.class("fieldset-legend")) { "Project - Elevation" }
        label(.class("input w-full")) {
          span(.class("label")) { SVG(.mountain) }
          input(
            .type(.number),
            .name("elevation"),
            .id("elevation"),
            .value(designInfo?.elevation),
            .min(0),
            .required
          )
        }
      }

      SubmitButton()
        .attributes(.class("btn-block"))
    }
  }
}
