import Elementary
import ManualSModels
import SharedStyleguide
import Tagged

struct PercentView: HTML, Sendable, StackStylable {

  @Environment(PercentViewEnvironment.$style) var style
  @Environment(PercentViewEnvironment.$displayStyle) private var displayStyle
  @Environment(PercentViewEnvironment.$symbolStyle) private var symbolStyle

  private let percent: Percent

  init(
    _ percent: Percent,
  ) {
    self.percent = percent
  }

  private var shouldApplyFlex: Bool {
    switch displayStyle {
    case .decimal, .default(includePercentSymbol: false): return false
    case .default(includePercentSymbol: true): return true
    }
  }

  var body: some HTML<HTMLTag.div> {
    div {
      switch displayStyle {
      case .decimal:

        NumberView(percent.decimal)
      case .default(let includePercentSymbol):
        NumberView(percent.rawValue)
        if includePercentSymbol {
          switch symbolStyle {
          case .default:
            span { "%" }
          case .svg:
            SVG(.percent)
          }
        }
      }
    }
    .attributes(.class("flex"), when: shouldApplyFlex)
    .applyStyle(style)
  }

  enum DisplayStyle: Sendable {
    case decimal
    case `default`(includePercentSymbol: Bool = true)
  }

  enum SymbolStyle: Sendable {
    case svg
    case `default`
  }

}

extension PercentView: SplitStylable {}
typealias PercentViewStyle = Tagged<PercentView, Style<HTMLTag.div>>

private enum PercentViewEnvironment {
  @TaskLocal static var style: PercentViewStyle = .init()
  @TaskLocal static var displayStyle: PercentView.DisplayStyle = .default()
  @TaskLocal static var symbolStyle: PercentView.SymbolStyle = .default
}

extension HTML {
  func percentViewStyle(_ style: PercentView.DisplayStyle) -> some HTML<Tag> {
    environment(PercentViewEnvironment.$displayStyle, style)
  }

  func percentViewStyle(_ style: PercentViewStyle) -> some HTML<Tag> {
    environment(PercentViewEnvironment.$style, style)
  }

  func percentViewSymbolStyle(_ style: PercentView.SymbolStyle) -> some HTML<Tag> {
    environment(PercentViewEnvironment.$symbolStyle, style)
  }
}
