import Elementary
import Tagged

struct Fieldset<Label: HTML, Content: HTML>: HTML {

  @Environment(FieldsetEnvironment.$style) var style
  @Environment(FieldsetEnvironment.$contentStyle) var contentStyle

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
      div {
        _content
      }
      .applyStyle(contentStyle)
    }
    .applyStyle(style)
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

enum FieldsetTag {}
enum FieldsetContentTag: StackStylable {}
typealias FieldsetStyle = Tagged<FieldsetTag, Style<HTMLTag.fieldset>>
typealias FieldsetContentStyle = Tagged<FieldsetContentTag, Style<HTMLTag.div>>

extension Tagged where Tag == FieldsetTag, RawValue == Style<HTMLTag.fieldset> {

  static func custom(_ attributes: HTMLAttribute<HTMLTag.fieldset>...) -> Self {
    .init(.init(attributes))
  }

  static var plain: Self { .init(.init()) }

  static var roundedBox: Self {
    .init(.init(.class("bg-base-200 border-base-300 rounded-box border p-4")))
  }

}

private enum FieldsetEnvironment {
  @TaskLocal fileprivate static var style = FieldsetStyle()
  @TaskLocal fileprivate static var contentStyle = FieldsetContentStyle()
}

extension HTML {
  func fieldsetStyle(_ style: FieldsetStyle) -> some HTML<Tag> {
    environment(FieldsetEnvironment.$style, style)
  }

  func fieldsetContentStyle(_ style: FieldsetContentStyle) -> some HTML<Tag> {
    environment(FieldsetEnvironment.$contentStyle, style)
  }
}

extension Fieldset: Sendable where Content: Sendable, Label: Sendable {}
