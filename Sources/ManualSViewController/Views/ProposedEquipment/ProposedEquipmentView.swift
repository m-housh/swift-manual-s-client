import Elementary
import ManualSModels
import SharedStyleguide

struct ProposedEquipmentView: HTML, Sendable {
  let proposedEquipment: ProposedEquipment?

  var body: some HTML<HTMLTag.div> {
    div(.class("w-full space-y-4")) {
      if proposedEquipment != nil {
        dl(.class("grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4")) {
          div(.class("flex justify-between py-2")) {
            dt(.class("text-base-content/70")) { "AFUE" }
            dd(.class("font-medium")) {
              if let afue = proposedEquipment?.afue {
                PercentView(afue)
              }
            }
          }
          div(.class("flex justify-between py-2")) {
            dt(.class("text-base-content/70")) { "SEER" }
            dd(.class("font-medium")) {
              if let seer = proposedEquipment?.seer {
                NumberView(seer, digits: 1)
              }
            }
          }
          div(.class("flex justify-between py-2")) {
            dt(.class("text-base-content/70")) { "HSPF" }
            dd(.class("font-medium")) {
              if let hspf = proposedEquipment?.hspf {
                NumberView(hspf, digits: 1)
              }
            }
          }
          div(.class("flex justify-between py-2")) {
            dt(.class("text-base-content/70")) { "Fan Speed" }
            dd(.class("font-medium")) {
              if let fanSpeed = proposedEquipment?.fanSpeed {
                span { fanSpeed.label }
              }
            }
          }
        }
        .percentViewStyle(.default)
        .percentViewSymbolStyle(.default)
      }

      Table {
        thead(.class("bg-base-300 text-base-content")) {
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
      .attributes(.class("table-sm"))
    }
  }

}
