import Elementary
import Tagged

struct Label: HTML, Sendable {

  @Environment(LabelEnvironment.$style) private var style
  private let label: String

  init(_ label: String) {
    self.label = label
  }

  init(_ label: () -> String) {
    self.init(label())
  }

  var body: some HTML<HTMLTag.span> {
    span { label }
      .style(style)
  }
}

enum LabelTag {}
typealias LabelStyle = Tagged<LabelTag, Style<HTMLTag.span>>

extension Tagged where Tag == LabelTag, RawValue == Style<HTMLTag.span> {

  static func `class`(_ color: String) -> Self {
    .init(HTMLAttribute.class(color))
  }
}

private enum LabelEnvironment {
  @TaskLocal fileprivate static var style = LabelStyle()
}

extension HTML {
  func labelStyle(_ style: LabelStyle) -> some HTML<Tag> {
    environment(LabelEnvironment.$style, style)
  }
}
