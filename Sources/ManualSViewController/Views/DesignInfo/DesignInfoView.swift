import Elementary
import ManualSModels
import SharedStyleguide

struct DesignInfoView: HTML, Sendable {
  let designInfo: DesignInfo?

  var body: some HTML {
    if let designInfo {
      div(.class("space-y-6")) {
        // Summer Conditions
        div {
          div(.class("flex items-center gap-2 mb-3")) {
            SVG(.sun)
            h3(.class("text-lg font-semibold text-yellow-600")) { "Summer Design Conditions" }
          }
          dl(.class("grid grid-cols-1 md:grid-cols-2 gap-4")) {
            div(.class("flex justify-between py-2")) {
              dt(.class("text-base-content/70")) { "Outdoor Temperature" }
              dd(.class("font-medium")) { TemperatureView(designInfo.summerOutdoorTemperature) }
            }
            div(.class("flex justify-between py-2")) {
              dt(.class("text-base-content/70")) { "Indoor Temperature" }
              dd(.class("font-medium")) { TemperatureView(designInfo.summerIndoorTemperature) }
            }
            div(.class("flex justify-between py-2")) {
              dt(.class("text-base-content/70")) { "Indoor Humidity" }
              dd(.class("font-medium")) { PercentView(designInfo.summerIndoorHumidity) }
            }
          }
        }

        // Winter Conditions
        div {
          div(.class("flex items-center gap-2 mb-3")) {
            SVG(.snowflake)
            h3(.class("text-lg font-semibold text-sky-600")) { "Winter Design Conditions" }
          }
          dl(.class("grid grid-cols-1 md:grid-cols-2 gap-4")) {
            div(.class("flex justify-between py-2")) {
              dt(.class("text-base-content/70")) { "Outdoor Temperature" }
              dd(.class("font-medium")) { TemperatureView(designInfo.winterOutdoorTemperature) }
            }
          }
        }

        // Project Info
        div {
          div(.class("flex items-center gap-2 mb-3")) {
            SVG(.mountain)
            h3(.class("text-lg font-semibold text-secondary")) { "Project Details" }
          }
          dl(.class("grid grid-cols-1 md:grid-cols-2 gap-4")) {
            div(.class("flex justify-between py-2")) {
              dt(.class("text-base-content/70")) { "Elevation" }
              dd(.class("font-medium")) { NumberView(designInfo.elevation) }
            }
          }
        }
      }
    }
  }
}
