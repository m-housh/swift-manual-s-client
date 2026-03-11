import Elementary
import ManualSModels
import SharedModels
import SharedStyleguide

struct DesignInfoTable: HTML, Sendable {
  let projectID: Project.ID
  let designInfo: DesignInfo?

  var body: some HTML<HTMLTag.table> {
    table(.class("table table-zebra text-lg")) {
      tbody {
        tr {
          td(.class("label")) {
            "Outdoor Design Temperature - Summer"
          }
          td {
            if let temperature = designInfo?.summerOutdoorTemperature {
              NumberView(temperature)
            }
          }
        }
        tr {
          td(.class("label")) {
            "Indoor Design Temperature - Summer"
          }
          td {
            if let temperature = designInfo?.summerIndoorTemperature {
              NumberView(temperature)
            }
          }
        }
        tr {
          td(.class("label")) {
            "Indoor Design Humidity - Summer"
          }
          td {
            if let humidity = designInfo?.summerIndoorHumidity {
              NumberView(humidity.rawValue)
            }
          }
        }
        tr {
          td(.class("label")) {
            "Outdoor Design Temperature - Winter"
          }
          td {
            if let temperature = designInfo?.winterOutdoorTemperature {
              NumberView(temperature)
            }
          }
        }
        tr {
          td(.class("label")) { "Project Elevation" }
          td {
            if let elevation = designInfo?.elevation {
              NumberView(elevation)
            }
          }
        }
      }
    }
  }
}
