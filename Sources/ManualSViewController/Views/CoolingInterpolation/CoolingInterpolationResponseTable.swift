import Elementary
import ManualSModels
import SharedStyleguide

struct CoolingInterpolationResponseTable: HTML, Sendable {

  let response: CoolingInterpolation.Response?
  let sizingLimits: SizingLimit.Cooling
  let flaggedCapacities: FlaggedCapacities

  var body: some HTML<HTMLTag.table> {
    table(.class("table table-zebra text-lg")) {
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
              FlaggedView(flaggedCapacities.total) {
                PercentView(response.capacityAsPercentOfLoad.total)
              }
            }
            td {
              FlaggedView(flaggedCapacities.sensible) {
                PercentView(response.capacityAsPercentOfLoad.sensible)
              }
            }
            td {
              FlaggedView(flaggedCapacities.latent) {
                PercentView(response.capacityAsPercentOfLoad.latent)
              }
            }
            td {}
          }
          tr {
            td(.class("label")) { "Oversizing Limits" }
            td { PercentView(sizingLimits.oversizing.total) }
            td {}
            td { PercentView(sizingLimits.oversizing.latent) }
            td {}
          }

        }
      }
    }
  }
}
