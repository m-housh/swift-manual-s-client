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

    var body: some HTML {
      switch interpolation {
      case .noInterpolation(let capacity):
        Row(
          label: interpolation.label,
          designAirflow: designAirflow,
          wetBulb: 63,
          capacity: capacity
        )
      case .oneWayIndoor(let oneWayIndoor):
        Row(
          label: "\(interpolation.label) - Below",
          designAirflow: designAirflow,
          wetBulb: oneWayIndoor.belowDesign.indoorWetBulbTemperature,
          capacity: oneWayIndoor.belowDesign.capacity
        )

        Row(
          label: "\(interpolation.label) - Above",
          designAirflow: designAirflow,
          wetBulb: oneWayIndoor.aboveDesign.indoorWetBulbTemperature,
          capacity: oneWayIndoor.aboveDesign.capacity
        )
      case .oneWayOutdoor(let oneWayOutdoor):
        Row(
          label: "\(interpolation.label) - Below",
          designAirflow: designAirflow,
          wetBulb: 63,
          capacity: oneWayOutdoor.belowDesign.capacity
        )

        Row(
          label: "\(interpolation.label) - Above",
          designAirflow: designAirflow,
          wetBulb: 63,
          capacity: oneWayOutdoor.aboveDesign.capacity
        )
      default:
        EmptyHTML()
      }
    }
  }

  struct Row: HTML, Sendable {
    let label: String
    let designAirflowColumn: Int
    let wetBulbColumn: Int
    let totalColumn: Double
    let sensibleColumn: Double
    let latentColumn: Double
    let shrColumn: Double

    init(
      label: String,
      designAirflow: Int,
      wetBulb: Int,
      capacity: CoolingCapacity
    ) {
      self.label = label
      self.designAirflowColumn = designAirflow
      self.wetBulbColumn = wetBulb
      self.totalColumn = capacity.total
      self.sensibleColumn = capacity.sensible
      self.latentColumn = capacity.latent
      self.shrColumn = capacity.sensibleHeatRatio
    }

    var body: some HTML<HTMLTag.tr> {
      tr {
        td(.class("label")) { label }
        td { NumberView(designAirflowColumn) }
        td { NumberView(wetBulbColumn) }
        td { NumberView(totalColumn) }
        td { NumberView(sensibleColumn) }
        td { NumberView(latentColumn) }
        td { NumberView(shrColumn) }
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
