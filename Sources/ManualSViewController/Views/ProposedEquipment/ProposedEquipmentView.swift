import Elementary
import ManualSModels
import SharedStyleguide

struct ProposedEquipmentView: HTML, Sendable {
  let proposedEquipment: ProposedEquipment?

  var body: some HTML<HTMLTag.div> {
    div(.class("flex justify-between gap-0 pb-2")) {
      // Equipment table
      div(.class("w-full")) {
        Table {
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
        Table {
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
                }
              }
            }
            tr {
              td(.class("label")) { "SEER" }
              td {
                if let seer = proposedEquipment?.seer {
                  div(.class("flex justify-end pe-8")) {
                    NumberView(seer, digits: 1)
                  }
                }
              }
            }
            tr {
              td(.class("label")) { "HSPF" }
              td {
                if let hspf = proposedEquipment?.hspf {
                  div(.class("flex justify-end pe-8")) {
                    NumberView(hspf, digits: 1)
                  }
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
          .percentViewStyle(.hstack(gap: 2), .end)
          .percentViewSymbolStyle(.svg, .label, .bold)
        }
      }
    }
  }
}
