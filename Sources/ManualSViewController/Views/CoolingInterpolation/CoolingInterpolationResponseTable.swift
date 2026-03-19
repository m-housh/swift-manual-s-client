import Elementary
import ManualSModels
import SharedStyleguide

struct CoolingInterpolationResponseTable: HTML, Sendable {
  let response: CoolingInterpolation.Response?

  var body: some HTML<HTMLTag.table> {
    Table {
      thead {
        tr {
          th { HTMLRaw("&nbsp;") }
          th { "Total" }
          th { "Sensible" }
          th { "Latent" }
          th { "SHR" }
        }
      }
      tbody {
        if let response {
          tr {
            td(.class("label")) { "Interpolated Capacity" }
            td { NumberView(response.interpolatedCapacity.total) }
            td { NumberView(response.interpolatedCapacity.sensible) }
            td { NumberView(response.interpolatedCapacity.latent) }
            td { NumberView(response.interpolatedCapacity.sensibleHeatRatio) }
          }
          tr {
            td(.class("label")) { "Altitude Adjustments" }
            td { NumberView(response.altitudeDeratings?.total.decimal ?? 1.0) }
            td { NumberView(response.altitudeDeratings?.sensible.decimal ?? 1.0) }
            td {}
            td {}
          }
          tr {
            td(.class("label")) { "Excess Latent" }
            td {}
            td {}
            td { NumberView(response.excessLatent, digits: 0) }
            td {}
          }
          tr {
            td(.class("label")) { "Capacity at Design" }
            td { NumberView(response.finalCapacityAtDesign.total) }
            td { NumberView(response.finalCapacityAtDesign.sensible) }
            td { NumberView(response.finalCapacityAtDesign.latent) }
            td { NumberView(response.finalCapacityAtDesign.sensibleHeatRatio) }
          }
          tr {
            td(.class("label")) { "Capacity as % of Design" }
            td {
              FlaggedView(response.flaggedCapacities.total) {
                PercentView(response.capacityAsPercentOfLoad.total)
              }
            }
            td {
              FlaggedView(response.flaggedCapacities.sensible) {
                PercentView(response.capacityAsPercentOfLoad.sensible)
              }
            }
            td {
              FlaggedView(response.flaggedCapacities.latent) {
                PercentView(response.capacityAsPercentOfLoad.latent)
              }
            }
            td {}
          }
          tr {
            td(.class("label")) { "Oversizing Limits" }
            td { PercentView(response.sizingLimits.oversizing.total) }
            td {}
            td { PercentView(response.sizingLimits.oversizing.latent) }
            td {}
          }
        }
      }
    }
    .percentViewStyle(.hstack(gap: 1))
    .percentViewSymbolStyle(.default)
  }
}
