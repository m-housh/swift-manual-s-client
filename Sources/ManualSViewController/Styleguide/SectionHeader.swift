import Elementary
import SharedStyleguide

// TODO: Better specify default modal attributes.
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
    modalAttributes: [HTMLAttribute<HTMLTag.div>] = [.class("max-w-[1080px] w-[90%]")],
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
    modalAttributes: [HTMLAttribute<HTMLTag.div>] = [.class("max-w-[1080px] w-[90%]")],
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

      button(.class("btn btn-primary btn-ghost"), .showModal(id: formID)) {
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
    modalAttributes: [HTMLAttribute<HTMLTag.div>] = [.class("max-w-[1080px] w-[90%]")],
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

extension SectionHeader: Sendable where Form: Sendable {}
