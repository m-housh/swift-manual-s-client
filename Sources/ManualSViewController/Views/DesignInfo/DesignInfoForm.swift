import Elementary
import ManualSModels
import SharedModels
import SharedStyleguide

struct DesignInfoForm: HTML, Sendable {

  let projectID: Project.ID
  let designInfo: DesignInfo?

  var body: some HTML<HTMLTag.form> {
    form(.class("space-y-4")) {
      h1(.class("text-3xl font-bold")) { "Design Information" }

      input(.hidden, .value(projectID), .name("projectID"))

      fieldset(.class("fieldset")) {
        legend(.class("fieldset-legend")) { "Outdoor Temperature - Summer" }
        label(.class("input w-full")) {
          span(.class("label")) { SVG(.thermometerSun) }
          input(
            .type(.number),
            .name("summerOutdoorTemperature"),
            .id("summerOutdoorTemperature"),
            .value(designInfo?.summerOutdoorTemperature),
            .min(0),
            .autofocus,
            .required
          )
        }
      }

      fieldset(.class("fieldset")) {
        legend(.class("fieldset-legend")) { "Indoor Temperature - Summer" }
        label(.class("input w-full")) {
          span(.class("label")) { SVG(.thermometer) }
          input(
            .type(.number),
            .name("summerIndoorTemperature"),
            .id("summerIndoorTemperature"),
            .value(designInfo?.summerIndoorTemperature),
            .min(0),
            .required
          )
        }
      }

      fieldset(.class("fieldset")) {
        legend(.class("fieldset-legend")) { "Indoor Humidity - Summer" }
        label(.class("input w-full")) {
          span(.class("label")) { SVG(.droplets) }
          input(
            .type(.number),
            .name("summerIndoorHumidity"),
            .id("summerIndoorHumidity"),
            .value(designInfo?.summerIndoorHumidity.rawValue),
            .min(0),
            .required
          )
        }
      }

      fieldset(.class("fieldset")) {
        legend(.class("fieldset-legend")) { "Outdoor Temperature - Winter" }
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
        }
      }

      fieldset(.class("fieldset")) {
        legend(.class("fieldset-legend")) { "Project Elevation" }
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
