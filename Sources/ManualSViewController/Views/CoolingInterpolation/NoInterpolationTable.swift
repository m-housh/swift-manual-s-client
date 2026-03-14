import Elementary
import ManualSModels
import SharedStyleguide

struct NoInterpolationTable: HTML, Sendable {

  let designAirflow: Int
  let returnWetBulb = 63
  let capacity: CoolingCapacity
  let manufacturersAdjustments: CoolingCapacityAdjustment?

  var body: some HTML<HTMLTag.table> {
    table(.class("table table-zebra text-lg")) {
      thead {
        tr {
          th { HTMLRaw("&nbsp;") }
          th { "Design CFM" }
          th { "Return Wet Bulb" }
          th { "Total" }
          th { "Sensible" }
          th { "Latent" }
          th { "SHR" }
        }
      }
      tbody {
        tr {
          td(.class("label")) { "No Interpolation" }
          td { NumberView(designAirflow) }
          td { NumberView(returnWetBulb) }
          td { NumberView(capacity.total) }
          td { NumberView(capacity.sensible) }
          td { NumberView(capacity.latent) }
          td { NumberView(capacity.sensibleHeatRatio) }
        }
        tr {
          td(.class("label")) { "Manufacturer's Adjustments" }
          td {}
          td {}
          td { PercentView(manufacturersAdjustments?.total ?? 100) }
          td { PercentView(manufacturersAdjustments?.sensible ?? 100) }
          td {}
          td {}
        }
        .percentViewStyle(.decimal)
      }
    }
  }

}
