import Elementary
import ManualSModels
import SharedStyleguide

struct ProposedEquipmentView: HTML, Sendable {
  let proposedEquipment: ProposedEquipment?

  var body: some HTML<HTMLTag.div> {
    div(.class("flex justify-between gap-0 pb-2")) {
      // Equipment table
      div(.class("w-full")) {
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

      div(.class("min-w-[350px]")) {
        table(.class("table table-zebra text-lg")) {
          thead {
            tr {
              th { HTMLRaw("&nbsp;") }
              th { HTMLRaw("&nbsp;") }
            }
          }
          tbody {
            tr {
              td(.class("label")) { "AFUE" }
              td {
                if let afue = proposedEquipment?.afue {
                  PercentView(afue)
                    .percentViewStyle(.split())
                  // .percentViewSymbolStyle(.svg)
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
