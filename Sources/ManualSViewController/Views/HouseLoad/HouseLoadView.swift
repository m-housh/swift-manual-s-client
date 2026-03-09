import Elementary
import ManualSModels
import SharedStyleguide

struct HouseLoadView: HTML, Sendable {
  let houseLoad: HouseLoad?

  var body: some HTML<HTMLTag.table> {
    // div(.class("border")) {
    //   div(.class("flex justify-between items-center bg-secondary border px-4 py-2")) {
    //     h2(.class("text-2xl font-bold")) { "Manual-J Load Calculation" }
    //     button(
    //       .class("btn btn-secondary"),
    //       .showModal(id: HouseLoadForm.id)
    //     ) {
    //       SVG(.squarePen)
    //     }
    //     .tooltip("Edit load calculation", position: .left)
    //
    //     Modal(open: false, displayCloseButton: true) {
    //       HouseLoadForm(houseLoad: houseLoad)
    //     }
    //   }
    table(.class("table table-zebra text-lg")) {
      thead {
        tr {
          th { "Heating" }
          th { "Total - Cooling" }
          th { "Sensible - Cooling" }
          th { "Latent - Cooling" }
          th { "SHR" }
        }
      }
      tbody {
        tr {
          td {
            if let heating = houseLoad?.heating {
              NumberView(heating)
            }
          }
          td {
            if let total = houseLoad?.cooling.total {
              NumberView(total)
            }
          }
          td {
            if let sensible = houseLoad?.cooling.sensible {
              NumberView(sensible)
            }
          }
          td {
            if let latent = houseLoad?.cooling.latent {
              NumberView(latent)
            }
          }
          td {
            if let shr = houseLoad?.cooling.sensibleHeatRatio {
              NumberView(shr)
            }
          }
        }
      }
    }
  }
  // }
}
