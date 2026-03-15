import Elementary
import SharedStyleguide
import Tagged

struct ElevationView: HTML, Sendable {

  @Environment(ElevationEnvironment.$digits) var digits
  @Environment(ElevationEnvironment.$symbol) var symbol
  @Environment(ElevationEnvironment.$symbolStyle) var symbolStyle
  @Environment(ElevationEnvironment.$style) var style

  let elevation: Double

  init(_ elevation: Double) {
    self.elevation = elevation
  }

  init(_ elevation: Int) {
    self.elevation = Double(elevation)
  }

  var body: some HTML<HTMLTag.div> {
    div {
      NumberView(elevation, digits: digits)
      if let symbol, symbol != .none {
        div {
          switch symbol {
          case .none:
            EmptyHTML()
          case .default:
            "ft."
          case .svg:
            SVG(.mountain)
          }
        }
        .style(symbolStyle)
      }
    }
    .style(style)
  }

  enum Symbol: Sendable {
    case `default`
    case none
    case svg
  }
}

private enum ElevationEnvironment {
  @TaskLocal static var digits: Int = 0
  @TaskLocal static var symbol: ElevationView.Symbol? = nil
  @TaskLocal static var symbolStyle: Tagged<ElevationView.Symbol, Style<HTMLTag.div>>? = nil
  @TaskLocal static var style: Tagged<ElevationView, Style<HTMLTag.div>>? = nil
}

extension HTML {
  func elevationStyle(digits: Int) -> some HTML<Tag> {
    environment(ElevationEnvironment.$digits, digits)
  }

  func elevationStyle(_ styles: Style<HTMLTag.div>...) -> some HTML<Tag> {
    environment(ElevationEnvironment.$style, .init(.combining(styles)))
  }

  func elevationSymbolStyle(_ styles: Style<HTMLTag.div>...) -> some HTML<Tag> {
    environment(ElevationEnvironment.$symbolStyle, .init(.combining(styles)))
  }

  func elevationSymbolStyle(
    _ symbol: ElevationView.Symbol,
    _ styles: Style<HTMLTag.div>...
  )
    -> some HTML<Tag>
  {
    environment(ElevationEnvironment.$symbolStyle, .init(.combining(styles)))
      .environment(ElevationEnvironment.$symbol, symbol)
  }
}
