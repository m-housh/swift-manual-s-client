import Elementary
import ManualSModels
import SharedStyleguide

struct PercentField: HTML, Sendable {
  let title: String
  let percent: Percent?
  let inputAttributes: [HTMLAttribute<HTMLTag.input>]

  init(
    _ title: String,
    percent: Percent? = nil,
    inputAttributes: [HTMLAttribute<HTMLTag.input>]
  ) {
    self.title = title
    self.percent = percent
    self.inputAttributes = inputAttributes
  }

  init(
    _ title: String,
    percent: Percent? = nil,
    inputAttributes: HTMLAttribute<HTMLTag.input>...
  ) {
    self.title = title
    self.percent = percent
    self.inputAttributes = inputAttributes
  }
  var body: some HTML<HTMLTag.label> {
    label(.class("input w-full")) {
      span(.class("label")) { title }
      input(
        .type(.number),
        .value(percent?.decimal ?? 1.0),
        .max(1.0),
        .min(0.0),
        .step(0.01)
      )
      .attributes(contentsOf: inputAttributes)
      span(.class("label")) { SVG(.percent) }
    }
  }
}
