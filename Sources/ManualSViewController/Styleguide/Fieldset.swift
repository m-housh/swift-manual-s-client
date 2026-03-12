import Elementary

struct Fieldset<Label: HTML, Content: HTML>: HTML {

  @Environment(FieldsetEnvironment.$style) var style

  private let label: Label
  private let _content: Content

  init(
    @HTMLBuilder content: () -> Content,
    @HTMLBuilder label: () -> Label
  ) {
    self._content = content()
    self.label = label()
  }

  var body: some HTML<HTMLTag.fieldset> {
    fieldset(.class("fieldset")) {
      label
      _content
    }
    .attributes(contentsOf: style.attributes)
  }
}

extension Fieldset where Label == legend<HTMLText> {

  init(
    _ label: String,
    @HTMLBuilder content: () -> Content,
  ) {
    self.init(
      content: content,
      label: { legend(.class("fieldset-legend")) { label } }
    )
  }
}

enum FieldsetStyle {
  case custom([HTMLAttribute<HTMLTag.fieldset>])
  case plain
  case roundedBox

  static var `default`: Self { .roundedBox }

  fileprivate var attributes: [HTMLAttribute<HTMLTag.fieldset>] {
    switch self {
    case .plain:
      return []
    case .roundedBox:
      return [.class("bg-base-200 border-base-300 rounded-box border p-4")]
    case .custom(let attributes):
      return attributes
    }
  }
}

private enum FieldsetEnvironment {
  @TaskLocal fileprivate static var style = FieldsetStyle.plain
}

extension HTML {
  func fieldsetStyle(_ style: FieldsetStyle) -> some HTML<Tag> {
    environment(FieldsetEnvironment.$style, style)
  }
}

extension Fieldset: Sendable where Content: Sendable, Label: Sendable {}
