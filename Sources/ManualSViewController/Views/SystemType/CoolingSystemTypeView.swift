import Elementary
import ManualSModels

struct CoolingSystemTypeView: HTML, Sendable {
  let systemType: SystemType.Cooling?

  var body: some HTML<HTMLTag.div> {
    div(.class("w-full")) {
      if let systemType {
        dl(.class("grid grid-cols-1 md:grid-cols-3 gap-4")) {
          div(.class("flex justify-between py-2")) {
            dt(.class("text-base-content/70")) { "Equipment" }
            dd(.class("font-medium")) { systemType.equipment.label }
          }
          div(.class("flex justify-between py-2")) {
            dt(.class("text-base-content/70")) { "Compressor" }
            dd(.class("font-medium")) { systemType.compressor.label }
          }
          div(.class("flex justify-between py-2")) {
            dt(.class("text-base-content/70")) { "Climate" }
            dd(.class("font-medium")) { 
              span { systemType.climate.labels.first! }
              span(.class("text-base-content/50 text-sm ml-2")) { "or \(systemType.climate.labels.last!)" }
            }
          }
        }
      }
    }
  }
}
