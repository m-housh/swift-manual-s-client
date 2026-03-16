import Elementary
import ManualSModels
import SharedStyleguide

struct HeatingInterpolationsView: HTML, Sendable {
  let projectID: Project.ID
  let interpolations: [(HeatingInterpolation, HeatingInterpolation.Response)]

  var body: some HTML {
    Table {
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
      case .electric(let kilowatts):
        div { "Electric..." }
      case .boilerOrFurnace(_):
        div { "Gas..." }
      }
    }
  }

}
