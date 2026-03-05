import Elementary
import ElementaryHTMX
import ManualSRouter
import SharedStyleguide

struct LoggedIn: HTML {
  let next: String

  init(next: String?) {
    self.next = next ?? ManualSRoute.router.path(for: .index)
  }

  init(next: ManualSRoute) {
    self.next = ManualSRoute.router.path(for: next)
  }

  var body: some HTML {
    div(
      .hx.get(next),
      .hx.target(id: "content"),
      .hx.pushURL(true),
      .hx.swap(.innerHTML),
      .hx.trigger(.event(.revealed)),
      .hx.indicator()
    ) {
      Indicator(size: .xl)
    }
  }
}
