import Elementary
import Tagged

struct Table<Content: HTML>: HTML {

  @Environment(TableEnvironment.$tableStyle) private var tableStyle

  private let _content: @Sendable () -> Content

  init(@HTMLBuilder content: @escaping @Sendable () -> Content) {
    self._content = content
  }

  var body: some HTML<HTMLTag.table> {
    table(.class("table")) {
      _content()
    }
    .style(tableStyle)
  }
}

enum TableTag {}
typealias TableStyle = Tagged<TableTag, Style<HTMLTag.table>>

extension Tagged where Tag == TableTag, RawValue == Style<HTMLTag.table> {
  static var `default`: Self { .init() }
  static var zebra: Self { .init(.class("table-zebra")) }
}

private enum TableEnvironment {
  @TaskLocal static var tableStyle: TableStyle = .default
}

extension HTML {

  func tableStyle(_ styles: [TableStyle]) -> some HTML<Tag> where Tag: HTMLTagDefinition {
    environment(TableEnvironment.$tableStyle, .init(.combining(styles.map(\.rawValue))))
  }

  func tableStyle(_ styles: TableStyle...) -> some HTML<Tag> where Tag: HTMLTagDefinition {
    tableStyle(styles)
  }

  func tableStyle(_ style: TableStyle) -> some HTML<Tag> {
    environment(TableEnvironment.$tableStyle, style)
  }
}
