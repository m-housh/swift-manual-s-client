import Elementary
import ElementaryHTMX
import ManualSRouter
import SharedStyleguide

struct LoadableView<Placeholder: HTML>: HTML, Sendable where Placeholder: Sendable {
  private let route: ManualSRoute
  private let placeholder: @Sendable () -> Placeholder

  init(
    route: ManualSRoute,
    @HTMLBuilder placeholder: @escaping @Sendable () -> Placeholder
  ) {
    self.route = route
    self.placeholder = placeholder
  }

  var body: some HTML {
    div(
      .class("relative"),
      .hx.get(route: route),
      .hx.target("this"),
      .hx.trigger(.event(.revealed).once()),
      .hx.swap(.innerHTML),
      .hx.indicator(),
    ) {
      div(.class("opacity-50")) {
        placeholder()
      }
      div(.class("absolute top-0 grid place-items-center h-full w-full z-50")) {
        Indicator()
      }
    }
  }
}
