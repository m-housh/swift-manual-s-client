import Elementary
import ManualSModels
import SharedModels
import SharedStyleguide

struct HeatingInterpolationsView: HTML, Sendable {
  let projectID: Project.ID
  let interpolations: [(HeatingInterpolation, HeatingInterpolation.Response)]

  var body: some HTML {
    table(.class("table text-lg")) {
      tbody {
        for interpolation in interpolations {
          Row(interpolation: interpolation.0, response: interpolation.1)
        }
      }
    }
  }

  // TODO: Rows may need a 'form'.
  struct Row: HTML, Sendable {
    let interpolation: HeatingInterpolation
    let response: HeatingInterpolation.Response

    var body: some HTML {
      switch interpolation.interpolation {
      case .heatPump(let capacity):
        HeatPumpTable(inputCapacity: capacity, response: response)
      default:
        EmptyHTML()
      }
    }
  }

}
