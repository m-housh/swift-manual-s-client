import Elementary
import ManualSModels
import SharedStyleguide

struct DesignInfoTable: HTML, Sendable {
  let projectID: Project.ID
  let designInfo: DesignInfo?

  var body: some HTML<HTMLTag.table> {
    Table {
      tbody {
        tr {
          td(.class("label")) {
            "Outdoor Design Temperature - Summer"
          }
          td {
            if let temperature = designInfo?.summerOutdoorTemperature {
              TemperatureView(temperature)
            }
          }
        }
        tr {
          td(.class("label")) {
            "Indoor Design Temperature - Summer"
          }
          td {
            if let temperature = designInfo?.summerIndoorTemperature {
              TemperatureView(temperature)
            }
          }
        }
        tr {
          td(.class("label")) {
            "Indoor Design Humidity - Summer"
          }
          td {
            if let humidity = designInfo?.summerIndoorHumidity {
              PercentView(humidity)
            }
          }
        }
        tr {
          td(.class("label")) {
            "Outdoor Design Temperature - Winter"
          }
          td {
            if let temperature = designInfo?.winterOutdoorTemperature {
              TemperatureView(temperature)
            }
          }
        }
        tr {
          td(.class("label")) { "Project Elevation" }
          td {
            if let elevation = designInfo?.elevation {
              ElevationView(elevation)
            }
          }
        }
      }
    }
    // TODO: Remove and use them in parent view??
    // .temperatureViewStyle(.hstack(gap: 2), .end, .init(.class("items-baseline")))
    // .temperatureViewSymbol(.svg, .label, .bold)
    // .percentViewStyle(.hstack(gap: 2), .end, .init(.class("items-baseline")))
    // .percentViewSymbolStyle(.svg, .label, .bold)
    // .elevationStyle(.hstack(gap: 2), .end, .init(.class("items-baseline")))
    // .elevationSymbolStyle(.svg, .label, .bold)
  }
}
