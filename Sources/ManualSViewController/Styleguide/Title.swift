import Elementary
import Tagged

struct Title: HTML, Sendable {
  @Environment(TitleEnvironment.$titleStyle) var titleStyle
  let title: String

  init(_ title: String) {
    self.title = title
  }

  init(_ title: () -> String) {
    self.title = title()
  }

  var body: some HTML<HTMLTag.h2> {
    h2 { title }.style(titleStyle)
  }
}

struct FormTitle: HTML, Sendable {
  @Environment(TitleEnvironment.$formTitleStyle) var style

  let title: String

  init(_ title: String) {
    self.title = title
  }

  init(_ title: () -> String) {
    self.title = title()
  }

  var body: some HTML<HTMLTag.h2> {
    h2 { title }.style(style)
  }
}

typealias TitleStyle = Tagged<Title, Style<HTMLTag.h2>>
extension TitleStyle {
  static let `default` = Self.init(.class("text-2xl font-bold"))
  static let cardTitle = Self.init(.class("card-title"))
}

typealias FormTitleStyle = Tagged<FormTitle, Style<HTMLTag.h2>>
extension FormTitleStyle {
  static let `default` = Self.init(.class("text-2xl font-bold mb-6"))
}

private enum TitleEnvironment {
  @TaskLocal static var titleStyle: TitleStyle = .default
  @TaskLocal static var formTitleStyle: FormTitleStyle = .default
}

extension HTML {
  func titleStyle(_ style: TitleStyle) -> some HTML<Tag> {
    environment(TitleEnvironment.$titleStyle, style)
  }
}
