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

  init(
    _ title: String? = nil,
    content: @autoclosure () -> Content
  ) {
    self.init(title, content: content)
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

struct SectionHeader<Form: HTML>: HTML {
  private let extraContent: String?
  private let formID: String
  private let form: Form
  private let modalAttributes: [HTMLAttribute<HTMLTag.div>]
  private let tooltip: String

  init(
    _ extraContent: String? = nil,
    tooltip: String,
    formID: String,
    modalAttributes: [HTMLAttribute<HTMLTag.div>] = [],
    @HTMLBuilder form: () -> Form
  ) {
    self.extraContent = extraContent
    self.formID = formID
    self.form = form()
    self.modalAttributes = modalAttributes
    self.tooltip = tooltip
  }

  init(
    _ extraContent: String? = nil,
    tooltip: String,
    formID: String,
    modalAttributes: [HTMLAttribute<HTMLTag.div>] = [],
    form: @autoclosure () -> Form
  ) {
    self.init(
      extraContent, tooltip: tooltip, formID: formID, modalAttributes: modalAttributes, form: form)
  }

  var body: some HTML<HTMLTag.div> {
    div(.class("flex")) {
      if let extraContent {
        span(.class("text-base-content font-bold")) {
          extraContent
        }
      }

      button(.class("btn btn-secondary btn-ghost"), .showModal(id: formID)) {
        SVG(.squarePen)
      }
      .tooltip(tooltip, position: .left)

      Modal(id: formID, open: false, displayCloseButton: true, attributes: modalAttributes) {
        form
      }
    }
    .attributes(.class("justify-between"), when: extraContent != nil)
    .attributes(.class("justify-end"), when: extraContent == nil)
  }
}

extension SectionHeader where Form: Identifiable, Form.ID == String {
  init(
    _ extraContent: String? = nil,
    tooltip: String,
    modalAttributes: [HTMLAttribute<HTMLTag.div>] = [],
    @HTMLBuilder form: () -> Form
  ) where Form: Identifiable, Form.ID == String {
    let form = form()
    self.init(
      extraContent,
      tooltip: tooltip,
      formID: form.id,
      modalAttributes: modalAttributes,
      form: form
    )
  }
}

extension Section: Sendable where Content: Sendable {}
extension SectionHeader: Sendable where Form: Sendable {}
