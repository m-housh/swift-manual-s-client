import Elementary
import ManualSModels
import SharedStyleguide

struct ProposedEquipmentView: HTML, Sendable {
  let proposedEquipment: ProposedEquipment?

  var body: some HTML<HTMLTag.div> {
    div {
      div(.class("flex justify-between items-center w-full bg-primary border px-4 py-2")) {
        h2(.class("text-2xl font-bold")) { "Proposed Equipment" }
        button(
          .class("btn btn-primary"),
          .showModal(id: ProposedEquipmentForm.id)
        ) {
          SVG(.squarePen)
        }
        .tooltip("Edit proposed equipment", position: .left)

        Modal(
          open: false,
          displayCloseButton: true,
          attributes: .class("max-w-none w-[90%]")
        ) {
          ProposedEquipmentForm(proposedEquipment: proposedEquipment)
        }
      }

      div(.class("flex justify-between")) {
        // Equipment table
        div(.class("border w-full")) {
          table(.class("table table-zebra text-lg")) {
            thead {
              tr {
                th { "Manufacturer" }
                th { "Type" }
                th { "Model" }
              }
            }
            tbody {
              if let equipment = proposedEquipment?.equipment, equipment.count > 0 {
                for item in equipment {
                  tr {
                    td { item.manufacturer }
                    td { item.equipmentType.label }
                    td { item.model }
                  }
                }
              }
            }
          }
        }
        div(.class("border min-w-[350px]")) {
          table(.class("table table-zebra text-lg")) {
            tbody {
              tr {
                td(.class("label")) { "AFUE" }
                td {
                  if let afue = proposedEquipment?.afue {
                    NumberView(afue.rawValue)
                  }
                }
              }
              tr {
                td(.class("label")) { "SEER" }
                td {
                  if let seer = proposedEquipment?.seer {
                    NumberView(seer, digits: 1)
                  }
                }
              }
              tr {
                td(.class("label")) { "HSPF" }
                td {
                  if let hspf = proposedEquipment?.hspf {
                    NumberView(hspf, digits: 1)
                  }
                }
              }
              tr {
                td(.class("label")) { "Fan Speed" }
                td {
                  if let fanSpeed = proposedEquipment?.fanSpeed {
                    span { fanSpeed.label }
                  }
                }
              }
            }
          }
        }
      }

    }
  }
}
