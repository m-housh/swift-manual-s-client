import Elementary
import SharedStyleguide

struct Section<Content: HTML>: HTML {

  private let title: String?
  private let _content: Content

  init(
    _ title: String? = nil,
    @HTMLBuilder content: () -> Content
  ) {
    self.title = title
    self._content = content()
  }

  var body: some HTML<HTMLTag.section> {
    section {
      div(.class("divider")) {
        if let title {
          Title { title }
            .attributes(.class("text-secondary"))
        }
      }
      _content
    }
  }
}

extension Section: Sendable where Content: Sendable {}

extension Section {

  init<Form: HTML, Body: HTML>(
    _ title: String? = nil,
    extraHeaderContent: String? = nil,
    formID: String,
    form: Form,
    @HTMLBuilder content: () -> Body
  )
  where
    Content == _HTMLTuple2<
      _AttributedElement<
        _AttributedElement<div<_HTMLTuple3<span<HTMLText>?, button<SVG>, Modal<Form>>>>
      >, Body
    >
  {
    self.init(title) {
      div(.class("flex items-center px-4 py-2")) {
        if let extraHeaderContent {
          span(.class("text-base-content font-bold")) { extraHeaderContent }
        }

        button(.class("btn btn-secondary btn-ghost"), .showModal(id: formID)) {
          SVG(.squarePen)
        }

        Modal(id: formID, open: false, displayCloseButton: true) {
          form
        }
      }
      .attributes(.class("justify-end"), when: extraHeaderContent == nil)
      .attributes(.class("justify-between"), when: extraHeaderContent != nil)

      content()
    }
  }

  init<Form: HTML, Body: HTML>(
    _ title: String? = nil,
    extraHeaderContent: String? = nil,
    formID: String,
    form: Form,
    content: @autoclosure () -> Body
  )
  where
    Content == _HTMLTuple2<
      _AttributedElement<
        _AttributedElement<div<_HTMLTuple3<span<HTMLText>?, button<SVG>, Modal<Form>>>>
      >, Body
    >
  {
    self.init(
      title,
      extraHeaderContent: extraHeaderContent,
      formID: formID,
      form: form,
      content: content
    )
  }

  init<Form: HTML, Body: HTML>(
    _ title: String? = nil,
    extraHeaderContent: String? = nil,
    form: Form,
    @HTMLBuilder content: () -> Body
  )
  where
    Content == _HTMLTuple2<
      _AttributedElement<
        _AttributedElement<div<_HTMLTuple3<span<HTMLText>?, button<SVG>, Modal<Form>>>>
      >, Body
    >,
    Form: Identifiable, Form.ID == String
  {
    self.init(
      title,
      extraHeaderContent: extraHeaderContent,
      formID: form.id,
      form: form,
      content: content
    )
  }

  init<Form: HTML, Body: HTML>(
    _ title: String? = nil,
    extraHeaderContent: String? = nil,
    form: Form,
    content: @autoclosure () -> Body
  )
  where
    Content == _HTMLTuple2<
      _AttributedElement<
        _AttributedElement<div<_HTMLTuple3<span<HTMLText>?, button<SVG>, Modal<Form>>>>
      >, Body
    >,
    Form: Identifiable, Form.ID == String
  {
    self.init(
      title,
      extraHeaderContent: extraHeaderContent,
      form: form,
      content: content
    )
  }

  init<Form: HTML>(
    _ title: String? = nil,
    extraHeaderContent: String? = nil,
    form: Form
  )
  where
    Content == _HTMLTuple2<
      _AttributedElement<
        _AttributedElement<div<_HTMLTuple3<span<HTMLText>?, button<SVG>, Modal<Form>>>>
      >, EmptyHTML
    >,
    Form: Identifiable, Form.ID == String
  {
    self.init(
      title,
      extraHeaderContent: extraHeaderContent,
      form: form,
      content: EmptyHTML.init
    )
  }
}
