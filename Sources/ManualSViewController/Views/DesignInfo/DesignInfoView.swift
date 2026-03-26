import Elementary
import ManualSModels
import SharedStyleguide

struct DesignInfoView: HTML, Sendable {
  let designInfo: DesignInfo?

  var body: some HTML {
    if let designInfo {
      div(.class("space-y-4")) {
        Card(title: "Summer", svg: .sun) {
          div(.class("grid grid-cols-2 justify-items-end gap-2 mt-3 mx-auto w-full")) {
            Row("Outdoor Temperature") { TemperatureView(designInfo.summerOutdoorTemperature) }
            Row("Indoor Temperature") { TemperatureView(designInfo.summerIndoorTemperature) }
            Row("Indoor Humidity") { PercentView(designInfo.summerIndoorHumidity) }
          }
          .percentViewStyle(.default)
          .percentViewSymbolStyle(.default)
        }
        // .labelStyle(.class("text-yellow-600"))
        // .attributes(.class("bg-yellow-300 border-yellow-600 font-bold"))

        Card(title: "Winter", svg: .snowflake) {
          div(.class("grid grid-cols-2 justify-items-end gap-2 mt-3 mx-auto w-full")) {
            Row("Outdoor Temperature") { TemperatureView(designInfo.winterOutdoorTemperature) }
          }
        }
        // .labelStyle(.class("text-sky-600 font-bold"))
        // .attributes(.class("bg-sky-300 border-sky-600 font-bold"))

        Card(title: "Project", svg: .mountain) {
          div(.class("grid grid-cols-2 justify-items-end gap-2 mt-3 mx-auto w-full")) {
            Row("Elevation") { NumberView(designInfo.elevation) }
          }
        }
        // .labelStyle(.class("text-white"))
        // .attributes(.class("bg-primary border-secondary text-white font-bold"))
      }
      .labelStyle(.class("label"))
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
      div(.class("p-4")) {
        div(.class("flex justify-items-start space-x-4 w-fit")) {
          SVG(svg)
          h2(.class("text-xl font-bold")) { title }
        }
        _body
      }
    }
  }

  struct Row<Content: HTML>: HTML {
    let label: String
    let _body: Content

    init(
      _ label: String,
      @HTMLBuilder body: () -> Content
    ) {
      self.label = label
      self._body = body()
    }

    var body: some HTML {
      Label { label }
      _body
    }
  }
}
