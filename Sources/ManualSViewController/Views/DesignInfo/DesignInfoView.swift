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
            h3(.class("text-lg font-semibold text-yellow-600")) {
              "Summer Design Conditions"
            }
          }
          div(.class("stats stats-vertical md:stats-horizontal shadow w-full")) {
            Stat("Outdoor Temp") {
              TemperatureView(designInfo.summerOutdoorTemperature)
            }
            Stat("Indoor Temp") {
              TemperatureView(designInfo.summerIndoorTemperature)
            }
            Stat("Indoor Humidity") {
              PercentView(designInfo.summerIndoorHumidity)
            }
          }
        }

        // Winter Conditions
        div {
          div(.class("flex items-center gap-2 mb-3")) {
            SVG(.snowflake)
            h3(.class("text-lg font-semibold text-sky-600")) {
              "Winter Design Conditions"
            }
          }
          div(.class("stats stats-vertical md:stats-horizontal shadow w-full")) {
            Stat("Outdoor Temp") {
              TemperatureView(designInfo.winterOutdoorTemperature)
            }
          }
        }

        // Project Info
        div {
          div(.class("flex items-center gap-2 mb-3")) {
            SVG(.mountain)
            h3(.class("text-lg font-semibold text-secondary")) {
              "Project Details"
            }
          }
          div(.class("stats stats-vertical md:stats-horizontal shadow w-full")) {
            Stat("Elevation") { NumberView(designInfo.elevation) }
          }
        }
      }
    }
  }
}
