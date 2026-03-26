import Elementary
import ManualSModels
import SharedStyleguide

struct ProposedEquipmentView: HTML, Sendable {
  let proposedEquipment: ProposedEquipment?

  var body: some HTML<HTMLTag.div> {
    div(.class("w-full space-y-4")) {
      if proposedEquipment != nil {
        div(.class("stats stats-vertical lg:stats-horizontal shadow w-full")) {
          Stat("AFUE") {
            if let afue = proposedEquipment?.afue {
              PercentView(afue)
            }
          }
          Stat("SEER") {
            if let seer = proposedEquipment?.seer {
              NumberView(seer, digits: 1)
            }
          }
          Stat("HSPF") {
            if let hspf = proposedEquipment?.hspf {
              NumberView(hspf, digits: 1)
            }
          }
          Stat("Fan Speed") {
            if let fanSpeed = proposedEquipment?.fanSpeed {
              span { fanSpeed.label }
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
