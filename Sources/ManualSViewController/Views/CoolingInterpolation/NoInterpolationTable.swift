import Elementary
import ManualSModels
import SharedStyleguide

struct NoInterpolationTable: HTML, Sendable {

  let response: CoolingInterpolation.Response
  let sizingLimits: SizingLimit.Cooling

  private var totalSuccessColor: String {
    let total = response.capacityAsPercentOfLoad.total
    if total.rawValue < sizingLimits.undersizing.total.rawValue
      || total.rawValue > sizingLimits.oversizing.total.rawValue
    {
      return "error"
    }
    return "success"
  }

  private var sensibleSuccessColor: String {
    let sensible = response.capacityAsPercentOfLoad.sensible
    if sensible.rawValue < sizingLimits.undersizing.sensible.rawValue {
      return "error"
    }
    return "success"
  }

  private var latentSuccessColor: String {
    let latent = response.capacityAsPercentOfLoad.latent
    if latent.rawValue < sizingLimits.undersizing.latent.rawValue
      || latent.rawValue > sizingLimits.oversizing.latent.rawValue
    {
      return "error"
    }
    return "success"
  }

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
            div(.class("flex text-\(totalSuccessColor) gap-2")) {
              PercentView(response.capacityAsPercentOfLoad.total)
              div(.class("rotate-45 mt-1")) {
                SVG(.flag)
              }
            }
          }
          td {

            div(.class("flex text-\(sensibleSuccessColor) gap-2")) {
              PercentView(response.capacityAsPercentOfLoad.sensible)
              div(.class("rotate-45 mt-1")) {
                SVG(.flag)
              }
            }
          }
          td {
            div(.class("flex text-\(latentSuccessColor) gap-2")) {
              PercentView(response.capacityAsPercentOfLoad.latent)
              div(.class("rotate-45 mt-1")) {
                SVG(.flag)
              }
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
