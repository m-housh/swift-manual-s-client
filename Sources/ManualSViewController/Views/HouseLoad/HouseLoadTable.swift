import Elementary
import ManualSModels
import SharedStyleguide

struct HouseLoadView: HTML, Sendable {
  let houseLoad: HouseLoad?

  var body: some HTML<HTMLTag.table> {
    Table {
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
