import Elementary

struct LabeledContent<Label: HTML, Content: HTML>: HTML {

  let label: Label
  let _content: Content

  init(
    @HTMLBuilder label: () -> Label,
    @HTMLBuilder content: () -> Content
  ) {
    self.label = label()
    self._content = content()
  }

  var body: some HTML<HTMLTag.div> {
    div {
      label
      _content
    }
  }
}

enum LabelTag {}
enum ContentTag {}


