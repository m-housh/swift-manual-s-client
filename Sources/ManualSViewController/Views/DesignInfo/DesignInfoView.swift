import Elementary
import ManualSModels
import SharedStyleguide

struct DesignInfoView: HTML, Sendable {
  let designInfo: DesignInfo?

  var body: some HTML {
    if let designInfo {
      div(.class("space-y-4")) {
        div(.class("grid grid-cols-1 lg:grid-cols-2 gap-4")) {
          Card(title: "Summer", svg: .sun) {
            div(.class("stats stats-vertical w-full")) {
              Stat("Outdoor Temperature") { TemperatureView(designInfo.summerOutdoorTemperature) }
            }
            div(.class("stats stats-vertical lg:stats-horizontal w-full")) {
              Stat("Indoor Temperature") { TemperatureView(designInfo.summerIndoorTemperature) }
              Stat("Indoor Humidity") { PercentView(designInfo.summerIndoorHumidity) }
            }
          }
          .percentViewStyle(.default)
          .percentViewSymbolStyle(.default)
          .attributes(.class("border border-yellow-400 text-yellow-400 rounded-box"))

          div(.class("space-y-4")) {
            Card(title: "Winter", svg: .snowflake) {
              div(.class("stats w-full")) {
                Stat("Outdoor Temperature") { TemperatureView(designInfo.winterOutdoorTemperature) }
              }
            }
            .attributes(.class("border border-sky-400 text-sky-400 rounded-box"))

            Card(title: "Project", svg: .mountain) {
              div(.class("stats w-full")) {
                Stat("Elevation") { NumberView(designInfo.elevation) }
              }
            }
            .attributes(.class("border border-secondary text-secondary rounded-box"))
          }
        }
      }
    }
  }

  struct Card<Content: HTML>: HTML {
    let title: String
    let svg: SVG.Key
    let _body: Content

    init(title: String, svg: SVG.Key, @HTMLBuilder body: () -> Content) {
      self.title = title
      self.svg = svg
      self._body = body()
    }

    var body: some HTML<HTMLTag.div> {
      div(.class("p-4 w-full")) {
        div(.class("flex justify-center space-x-4 w-full")) {
          SVG(svg)
          h2(.class("text-xl font-bold")) { title }
        }
        _body
      }
    }
  }

}
