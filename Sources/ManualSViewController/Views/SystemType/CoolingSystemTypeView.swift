import Elementary
import ManualSModels
import SharedStyleguide

struct CoolingSystemTypeView: HTML, Sendable {
  let systemType: SystemType.Cooling?

  var body: some HTML<HTMLTag.div> {
    div(.class("w-full")) {
      if let systemType {
        div(.class("stats stats-vertical lg:stats-horizontal shadow w-full")) {
          Stat("Equipment") { systemType.equipment.label }
          Stat("Compressor") { systemType.compressor.label }
          Stat("Climate", description: "or \(systemType.climate.labels.last!)") {
            systemType.climate.labels.first!
          }
        }
      }
    }
  }
}
