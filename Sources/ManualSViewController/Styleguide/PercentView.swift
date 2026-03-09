import Elementary
import ManualSModels
import SharedStyleguide

struct PercentView: HTML, Sendable {

  let percent: Percent
  let includePercentSymbol: Bool
  let keyPath: KeyPath<Percent, Double>

  init(
    _ percent: Percent,
    includePercentSymbol: Bool = true,
    toValue keyPath: KeyPath<Percent, Double> = \.rawValue
  ) {
    self.percent = percent
    self.includePercentSymbol = includePercentSymbol
    self.keyPath = keyPath
  }

  var body: some HTML<HTMLTag.div> {
    div(.class("flex")) {
      NumberView(percent[keyPath: keyPath])
      if includePercentSymbol {
        span { "%" }
      }
    }
  }

  static func multiplier(_ percent: Percent) -> Self {
    .init(percent, includePercentSymbol: false, toValue: \.decimal)
  }
}
