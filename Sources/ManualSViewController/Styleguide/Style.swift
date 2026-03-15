import Elementary
import Tagged

struct Style<Tag> where Tag: HTMLTagDefinition {
  fileprivate var attributes: [HTMLAttribute<Tag>]

  init(_ attributes: [HTMLAttribute<Tag>] = []) {
    self.attributes = attributes
  }

  init(_ attributes: HTMLAttribute<Tag>...) {
    self.init(attributes)
  }

  static func combining(_ styles: [Self]) -> Self {
    .init(styles.reduce(into: []) { $0 += $1.attributes })
  }

  static func combining(_ styles: Self...) -> Self {
    combining(styles)
  }
}

extension Style: Sendable where Tag: Sendable {}

extension HTML where Tag: HTMLTrait.Attributes.Global {

  func style(_ styles: [Style<Tag>]) -> some HTML<Tag> {
    attributes(contentsOf: styles.reduce(into: []) { $0 += $1.attributes })
  }

  func style(_ styles: Style<Tag>...) -> some HTML<Tag> {
    style(styles)
  }

  func style(_ style: Style<Tag>) -> some HTML<Tag> {
    attributes(contentsOf: style.attributes)
  }

  func style(_ style: Style<Tag>?) -> some HTML<Tag> {
    attributes(contentsOf: style?.attributes ?? [])
  }

  func style<T>(_ style: Tagged<T, Style<Tag>>) -> some HTML<Tag> {
    attributes(contentsOf: style.rawValue.attributes)
  }

  func style<T>(_ style: Tagged<T, Style<Tag>>?) -> some HTML<Tag> {
    attributes(contentsOf: style?.attributes ?? [])
  }
}

extension Tagged {

  init<T>(
    _ attributes: [HTMLAttribute<T>] = []
  ) where RawValue == Style<T>, T: HTMLTagDefinition {
    self.init(Style<T>(attributes))
  }

  init<T>(
    _ attributes: HTMLAttribute<T>...
  ) where RawValue == Style<T>, T: HTMLTagDefinition {
    self.init(Style<T>(attributes))
  }

  init<T>(
    _ styles: Self...
  ) where RawValue == Style<T>, T: HTMLTagDefinition {
    self.init(Style.combining(styles.map(\.rawValue)))
  }
}

protocol StackStylable: HTMLTagDefinition, HTMLTrait.Attributes.Global {}
extension Style where Tag: StackStylable {
  static func vstack(gap: Int = 4) -> Self {
    .init(.class("space-y-\(gap)"))
  }

  static func hstack(gap: Int = 4) -> Self {
    .init(.class("flex gap-\(gap)"))
  }
}

protocol SplitStylable: HTMLTagDefinition, HTMLTrait.Attributes.Global {}
extension Style where Tag: SplitStylable {
  static var split: Self {
    .init(.class("flex flex-wrap justify-between w-full"))
  }
}

protocol TextStylable: HTMLTagDefinition, HTMLTrait.Attributes.Global {}
extension Style where Tag: TextStylable {
  static var label: Self { .init(.class("text-base-content/50")) }
  static var bold: Self { .init(.class("font-bold")) }
}

extension HTMLElement where Tag: StackStylable {
  init(_ styles: Style<Tag>..., @HTMLBuilder content: () -> Content) {
    self.init(
      attributes: styles.reduce(into: []) { $0 += $1.attributes }
    ) { content() }
  }
}

protocol JustifyStyleable: HTMLTagDefinition, HTMLTrait.Attributes.Global {}
extension Style where Tag: JustifyStyleable {
  static var end: Self { .init(.class("justify-end")) }
  static var start: Self { .init(.class("justify-start")) }
}

extension HTMLTag.div: SplitStylable {}
extension HTMLTag.div: StackStylable {}
extension HTMLTag.div: TextStylable {}
extension HTMLTag.div: JustifyStyleable {}
extension HTMLTag.span: TextStylable {}
