import Elementary
import ManualSModels
import SharedStyleguide

extension NumberView {

  init(
    _ percent: Percent,
    digits: Int = 2
  ) {
    self.init(percent.decimal, digits: digits)
  }
}
