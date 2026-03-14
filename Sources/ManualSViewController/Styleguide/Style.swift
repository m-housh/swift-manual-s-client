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

  func applyStyle(_ styles: [Style<Tag>]) -> some HTML<Tag> {
    attributes(contentsOf: styles.reduce(into: []) { $0 += $1.attributes })
  }

  func applyStyle(_ styles: Style<Tag>...) -> some HTML<Tag> {
    applyStyle(styles)
  }

  func applyStyle(_ style: Style<Tag>) -> some HTML<Tag> {
    attributes(contentsOf: style.attributes)
  }

  func applyStyle<T>(_ style: Tagged<T, Style<Tag>>) -> some HTML<Tag> {
    attributes(contentsOf: style.rawValue.attributes)
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

protocol StackStylable {}

extension Tagged {
  static func vstack<T>(gap: Int = 4) -> Self
  where
    RawValue == Style<T>,
    T: HTMLTagDefinition,
    T: HTMLTrait.Attributes.Global,
    Tag: StackStylable
  {
    .init(.class("space-y-\(gap)"))
  }

  static func hstack<T>(gap: Int = 4) -> Self
  where
    RawValue == Style<T>,
    T: HTMLTagDefinition,
    T: HTMLTrait.Attributes.Global,
    Tag: StackStylable
  {
    .init(.class("flex gap-\(gap)"))
  }
}

protocol SplitStylable {}
extension Tagged where Tag: SplitStylable {

  static func split<T>() -> Self
  where
    RawValue == Style<T>,
    T: HTMLTagDefinition,
    T: HTMLTrait.Attributes.Global
  {
    .init(.class("flex flex-wrap justify-between w-full"))
  }
}

protocol TextStylable: HTMLTagDefinition, HTMLTrait.Attributes.Global {}
extension Style where Tag: TextStylable {
  static var label: Self { .init(.class("text-base-content/50")) }
  static var bold: Self { .init(.class("font-bold")) }
}
extension HTMLTag.div: TextStylable {}
extension HTMLTag.span: TextStylable {}
