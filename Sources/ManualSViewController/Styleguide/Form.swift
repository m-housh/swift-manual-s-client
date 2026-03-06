import Elementary

struct Form<Title: HTML, Content: HTML>: HTML {
  private let attributes: [HTMLAttribute<HTMLTag.form>]
  private let title: Title
  private let _content: Content

  init(
    _ attributes: [HTMLAttribute<HTMLTag.form>],
    @HTMLBuilder title: () -> Title,
    @HTMLBuilder content: () -> Content
  ) {
    self.attributes = attributes
    self.title = title()
    self._content = content()
  }

  init(
    _ attributes: HTMLAttribute<HTMLTag.form>...,
    @HTMLBuilder title: () -> Title,
    @HTMLBuilder content: () -> Content
  ) {
    self.attributes = attributes
    self.title = title()
    self._content = content()
  }

  var body: some HTML<HTMLTag.form> {
    form(.class("space-y-4")) {
      title
      _content
    }
    .attributes(contentsOf: attributes)
  }

}

extension Form where Title == EmptyHTML {

  init(
    _ attributes: HTMLAttribute<HTMLTag.form>...,
    @HTMLBuilder content: () -> Content
  ) {
    self.init(attributes, title: { EmptyHTML() }, content: content)
  }
}

extension Form where Title == FormTitle {

  init(
    title: String,
    _ attributes: HTMLAttribute<HTMLTag.form>...,
    @HTMLBuilder content: () -> Content
  ) {
    self.init(attributes, title: { FormTitle(title) }, content: content)
  }
}
