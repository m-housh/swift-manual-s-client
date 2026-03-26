import Elementary
import ManualSModels

struct CoolingSystemTypeView: HTML, Sendable {
  let systemType: SystemType.Cooling?

  var body: some HTML<HTMLTag.div> {
    div(.class("stats stats-vertical lg:stats-horizontal shadow w-full")) {
      if let systemType {
        Stat("Equipment") { systemType.equipment.label }
        Stat("Compressor") { systemType.compressor.label }
        Stat("Climate") { systemType.climate.label }
      }
    }
  }
}
