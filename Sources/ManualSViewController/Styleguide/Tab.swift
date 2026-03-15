import Elementary
import Tagged

struct Tab<Content: HTML>: HTML {
  @Environment(TabEnvironment.$tabContentStyle) var style

  private let _content: @Sendable () -> Content
  private let title: String
  private let name: String
  private let checked: Bool

  public init(
    title: String,
    name: String,
    checked: Bool,
    @HTMLBuilder content: @escaping @Sendable () -> Content
  ) {
    self.title = title
    self.name = name
    self.checked = checked
    self._content = content
  }

  var body: some HTML {

    input(
      .type(.radio),
      .name(name), .class("tab"),
      .init(name: "aria-label", value: title)
    )
    .attributes(.checked, when: checked)

    div(.class("tab-content")) {
      _content()
    }
    .style(style)
  }
}

private enum TabEnvironment {
  @TaskLocal static var tabContentStyle: TabContentStyle = .bordered
}

enum TabContentTag {}
typealias TabContentStyle = Tagged<TabContentTag, Style<HTMLTag.div>>
extension TabContentStyle {
  static let bordered = Self(.class("border-base-300 p-6"))
}
