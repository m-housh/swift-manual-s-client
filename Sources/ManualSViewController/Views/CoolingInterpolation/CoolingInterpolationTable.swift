import Elementary
import Foundation
import ManualSModels
import ManualSRouter
import SharedModels
import SharedStyleguide

struct InterpolationTable: HTML, Sendable {

  let projectID: Project.ID
  let coolingInterpolation: CoolingInterpolation?

  private var manufacturersAdjustments: CoolingCapacityAdjustment? {
    coolingInterpolation?.manufacturersAdjustments
  }

  var body: some HTML<HTMLTag.table> {
    table(.class("table")) {
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
        if let coolingInterpolation {
          InterpolationRow(
            designAirflow: coolingInterpolation.designAirflow,
            interpolation: coolingInterpolation.interpolation
          )
          tr {
            td(.class("label")) { "Manufacturer's Adjustments" }
            td {}
            td {}
            td { PercentView.multiplier(manufacturersAdjustments?.total ?? 100) }
            td { PercentView.multiplier(manufacturersAdjustments?.sensible ?? 100) }
            td {}
            td {}
          }
        }
      }
    }
  }

  // TODO: Trash button ??
  struct InterpolationRow: HTML, Sendable {
    let designAirflow: Int
    let interpolation: CoolingInterpolation.Interpolation
    // let interpolationResult: CoolingInterpolation.Response

    var body: some HTML<HTMLTag.tr> {
      tr {
        td(.class("label")) { interpolation.label }
        td { NumberView(designAirflow) }
        switch interpolation {
        case .noInterpolation(let capacity):
          td { NumberView(63) }
          td { NumberView(capacity.total) }
          td { NumberView(capacity.sensible) }
          td { NumberView(capacity.latent) }
          td { NumberView(capacity.sensibleHeatRatio) }
        default:
          EmptyHTML()
        }
      }
    }
  }

}

extension CoolingInterpolation.Interpolation {
  fileprivate var label: String {
    switch self {
    case .noInterpolation: return "No Interpolation"
    case .oneWayIndoor: return "One Way - Indoor"
    case .oneWayOutdoor: return "One Way - Outdoor"
    case .twoWay: return "Two Way"
    }
  }
}
