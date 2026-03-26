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

      div(.class("min-w-[280px] mt-6")) {
        Card(
          afue: proposedEquipment?.afue,
          seer: proposedEquipment?.seer,
          hspf: proposedEquipment?.hspf,
          fanSpeed: proposedEquipment?.fanSpeed
        )
        // Table {
        //   thead {
        //     tr {
        //       th { HTMLRaw("&nbsp;") }
        //       th { HTMLRaw("&nbsp;") }
        //     }
        //   }
        //   tbody {
        //     tr {
        //       td(.class("label")) { "AFUE" }
        //       td {
        //         if let afue = proposedEquipment?.afue {
        //           PercentView(afue)
        //         }
        //       }
        //     }
        //     tr {
        //       td(.class("label")) { "SEER" }
        //       td {
        //         if let seer = proposedEquipment?.seer {
        //           div(.class("flex justify-end pe-8")) {
        //             NumberView(seer, digits: 1)
        //           }
        //         }
        //       }
        //     }
        //     tr {
        //       td(.class("label")) { "HSPF" }
        //       td {
        //         if let hspf = proposedEquipment?.hspf {
        //           div(.class("flex justify-end pe-8")) {
        //             NumberView(hspf, digits: 1)
        //           }
        //         }
        //       }
        //     }
        //     tr {
        //       td(.class("label")) { "Fan Speed" }
        //       td {
        //         if let fanSpeed = proposedEquipment?.fanSpeed {
        //           span { fanSpeed.label }
        //         }
        //       }
        //     }
        //   }
        //   .percentViewStyle(.hstack(gap: 2), .end)
        //   .percentViewSymbolStyle(.svg, .label, .bold)
        // }
      }
    }
  }

  struct Card: HTML, Sendable {
    let afue: Percent?
    let seer: Double?
    let hspf: Double?
    let fanSpeed: ProposedEquipment.FanSpeed?

    var body: some HTML {
      // div(.class("border rounded-box shadow-lg p-2")) {
      div(.class("p-2")) {
        div(.class("grid grid-cols-2 gap-x-4 gap-y-2 justify-items-end mx-auto w-fit")) {
          Row("AFUE") {
            if let afue {
              PercentView(afue)
            } else {
              div {}
            }
          }
          Row("SEER") {
            if let seer {
              NumberView(seer, digits: 1)
            } else {
              div {}
            }
          }
          Row("HSPF") {
            if let hspf {
              NumberView(hspf, digits: 1)
            } else {
              div {}
            }
          }
          Row("Fan") {
            if let fanSpeed {
              span { fanSpeed.label }
            } else {
              div {}
            }
          }
        }
      }
    }

    struct Row<Content: HTML>: HTML {
      let label: String
      let _body: Content

      init(_ label: String, @HTMLBuilder body: () -> Content) {
        self.label = label
        self._body = body()
      }

      var body: some HTML {
        span(.class("label")) { label }
        _body
      }
    }
  }
}
