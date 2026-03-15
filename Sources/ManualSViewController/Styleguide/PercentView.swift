import Elementary
import ManualSModels
import SharedStyleguide
import Tagged

struct PercentView: HTML, Sendable {

  @Environment(PercentViewEnvironment.$style) var style
  @Environment(PercentViewEnvironment.$displayStyle) private var displayStyle
  @Environment(PercentViewEnvironment.$symbol) private var symbol
  @Environment(PercentViewEnvironment.$symbolStyle) private var symbolStyle

  private let percent: Percent

  init(_ percent: Percent) {
    self.percent = percent
  }

  var body: some HTML<HTMLTag.div> {
    div {
      switch displayStyle {
      case .decimal:
        NumberView(percent.decimal)
      case .default:
        NumberView(percent.rawValue)
      }

      if let symbol {
        div {
          switch symbol {
          case .svg:
            SVG(.percent)
          case .default:
            "%"
          case .none:
            EmptyHTML()
          }
        }
        .style(symbolStyle)
      }
    }
    .attributes(.class("flex"), when: symbol != nil)
    .style(style)
  }

  enum DisplayStyle: Sendable {
    case decimal
    case `default`
  }

  enum Symbol: Sendable {
    case `default`
    case none
    case svg
  }

}

typealias PercentViewStyle = Tagged<PercentView, Style<HTMLTag.div>>

private enum PercentViewEnvironment {
  @TaskLocal static var style: Tagged<PercentView, Style<HTMLTag.div>>? = nil
  @TaskLocal static var displayStyle: PercentView.DisplayStyle = .default
  @TaskLocal static var symbol: PercentView.Symbol? = nil
  @TaskLocal static var symbolStyle: Tagged<PercentView.Symbol, Style<HTMLTag.div>>? = nil
}

extension HTML {

  func percentViewStyle(
    _ styles: Style<HTMLTag.div>...
  ) -> some HTML<Tag> {
    environment(PercentViewEnvironment.$style, .init(.combining(styles)))
  }

  func percentViewStyle(
    _ displayStyle: PercentView.DisplayStyle,
    _ styles: Style<HTMLTag.div>...
  ) -> some HTML<Tag> {
    environment(PercentViewEnvironment.$displayStyle, displayStyle)
      .environment(PercentViewEnvironment.$style, .init(.combining(styles)))
  }

  func percentViewSymbolStyle(
    _ symbol: PercentView.Symbol,
    _ styles: Style<HTMLTag.div>...
  ) -> some HTML<Tag> {
    environment(PercentViewEnvironment.$symbol, symbol)
      .environment(PercentViewEnvironment.$symbolStyle, .init(.combining(styles)))
  }

  func percentViewSymbolStyle(_ styles: Style<HTMLTag.div>...) -> some HTML<Tag> {
    environment(PercentViewEnvironment.$symbolStyle, .init(.combining(styles)))
  }
}
