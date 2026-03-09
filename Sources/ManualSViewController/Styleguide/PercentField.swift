import Elementary
import ManualSModels
import SharedStyleguide

struct PercentField: HTML, Sendable {
  let title: String
  let percent: Percent?
  let toValue: KeyPath<Percent, Double>
  let inputAttributes: [HTMLAttribute<HTMLTag.input>]
  let svg: SVG.Key

  init(
    _ title: String,
    percent: Percent? = nil,
    toValue: KeyPath<Percent, Double> = \.decimal,
    svg: SVG.Key = .close,
    inputAttributes: [HTMLAttribute<HTMLTag.input>]
  ) {
    self.title = title
    self.percent = percent
    self.inputAttributes = inputAttributes
    self.toValue = toValue
    self.svg = svg
  }

  init(
    _ title: String,
    percent: Percent? = nil,
    toValue: KeyPath<Percent, Double> = \.decimal,
    svg: SVG.Key = .close,
    inputAttributes: HTMLAttribute<HTMLTag.input>...
  ) {
    self.init(
      title,
      percent: percent,
      toValue: toValue,
      svg: svg,
      inputAttributes: inputAttributes
    )
  }
  var body: some HTML<HTMLTag.label> {
    label(.class("input w-full")) {
      span(.class("label")) { title }
      input(
        .type(.number),
        .value(percent?[keyPath: toValue] ?? 1.0),
        .max(1.0),
        .min(0.0),
        .step(0.01)
      )
      .attributes(contentsOf: inputAttributes)
      span(.class("label")) { SVG(svg) }
    }
  }
}
