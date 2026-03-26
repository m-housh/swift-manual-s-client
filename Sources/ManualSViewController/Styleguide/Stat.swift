import Elementary

struct Stat<Content: HTML>: HTML {
  private let title: String
  private let description: String?
  private let value: Content

  init(
    _ title: String,
    description: String? = nil,
    @HTMLBuilder value: () -> Content
  ) {
    self.title = title
    self.description = description
    self.value = value()
  }

  var body: some HTML<HTMLTag.div> {
    div(.class("stat")) {
      div(.class("stat-title")) { title }
      div(.class("stat-value")) { value }
      if let description {
        div(.class("stat-desc")) { description }
      }
    }
  }
}
extension Stat: Sendable where Content: Sendable {}
