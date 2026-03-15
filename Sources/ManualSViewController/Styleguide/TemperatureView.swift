import Elementary
import SharedStyleguide
import Tagged

struct TemperatureView: HTML, Sendable {

  @Environment(TemperatureViewEnvironment.$digits) private var digits
  @Environment(TemperatureViewEnvironment.$style) private var style
  @Environment(TemperatureViewEnvironment.$symbol) private var symbol
  @Environment(TemperatureViewEnvironment.$symbolStyle) private var symbolStyle

  private let temperature: Double
  private let forceZeroDigits: Bool

  init(_ temperature: Double) {
    self.temperature = temperature
    self.forceZeroDigits = false
  }

  init(_ temperature: Int) {
    self.temperature = Double(temperature)
    self.forceZeroDigits = true
  }

  private var shouldApplyFlex: Bool {
    if let symbol, symbol != .none { return true }
    return false
  }

  var body: some HTML<HTMLTag.div> {
    div {
      NumberView(temperature, digits: forceZeroDigits ? 0 : digits)
      if let symbol, symbol != .none {
        div {
          switch symbol {
          case .default:
            span { "°F" }
          case .none:
            EmptyHTML()
          case .svg:
            SVG(.fahrenheit)
          }
        }
        .style(symbolStyle)
      }
    }
    .attributes(.class("flex"), when: shouldApplyFlex)
    .style(style)

  }

  enum Symbol: Sendable {
    case none
    case `default`
    case svg
  }
}

private enum TemperatureViewEnvironment {
  @TaskLocal static var digits: Int = 2
  @TaskLocal static var symbol: TemperatureView.Symbol? = .default
  @TaskLocal static var symbolStyle: Tagged<TemperatureView.Symbol, Style<HTMLTag.div>>? = nil
  @TaskLocal static var style: Tagged<TemperatureView, Style<HTMLTag.div>>? = nil
}

extension HTML {
  func temperatureViewStyle(digits: Int) -> some HTML<Tag> {
    environment(TemperatureViewEnvironment.$digits, digits)
  }

  func temperatureViewStyle(_ style: Style<HTMLTag.div>) -> some HTML<Tag> {
    environment(TemperatureViewEnvironment.$style, .init(style))
  }

  func temperatureViewStyle(_ styles: Style<HTMLTag.div>...) -> some HTML<Tag> {
    environment(TemperatureViewEnvironment.$style, .init(.combining(styles)))
  }

  func temperatureViewSymbol(
    _ symbol: TemperatureView.Symbol,
    _ styles: Style<HTMLTag.div>...
  ) -> some HTML<Tag> {
    environment(TemperatureViewEnvironment.$symbol, symbol)
      .environment(TemperatureViewEnvironment.$symbolStyle, .init(.combining(styles)))
  }

  func temperatureViewSymbolStyle(_ style: Style<HTMLTag.div>) -> some HTML<Tag> {
    environment(TemperatureViewEnvironment.$symbolStyle, .init(style))
  }

  func temperatureViewSymbolStyle(_ styles: Style<HTMLTag.div>...) -> some HTML<Tag> {
    environment(TemperatureViewEnvironment.$symbolStyle, .init(.combining(styles)))
  }

}
