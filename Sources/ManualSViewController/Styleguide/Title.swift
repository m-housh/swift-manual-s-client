import Elementary

struct Title: HTML, Sendable {
  let title: String

  init(_ title: String) {
    self.title = title
  }

  init(_ title: () -> String) {
    self.title = title()
  }

  var body: some HTML<HTMLTag.h2> {
    h2(.class("text-2xl font-bold")) { title }
  }
}

struct FormTitle: HTML, Sendable {
  let title: String

  init(_ title: String) {
    self.title = title
  }

  init(_ title: () -> String) {
    self.title = title()
  }

  var body: some HTML<HTMLTag.h2> {
    Title(title)
      .attributes(.class("mb-6"))
  }
}
