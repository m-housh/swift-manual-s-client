import Elementary
import ManualSModels
import SharedStyleguide

struct HouseLoadView: HTML, Sendable {
  let houseLoad: HouseLoad?

  var body: some HTML<HTMLTag.div> {
    div(.class("w-full")) {
      if let houseLoad {
        dl(.class("grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4")) {
          div(.class("flex justify-between py-2")) {
            dt(.class("text-base-content/70")) { "Heating" }
            dd(.class("font-medium")) { NumberView(houseLoad.heating) }
          }
          div(.class("flex justify-between py-2")) {
            dt(.class("text-base-content/70")) { "Cooling Total" }
            dd(.class("font-medium")) { NumberView(houseLoad.cooling.total) }
          }
          div(.class("flex justify-between py-2")) {
            dt(.class("text-base-content/70")) { "Cooling Sensible" }
            dd(.class("font-medium")) { NumberView(houseLoad.cooling.sensible) }
          }
          div(.class("flex justify-between py-2")) {
            dt(.class("text-base-content/70")) { "Cooling Latent" }
            dd(.class("font-medium")) { NumberView(houseLoad.cooling.latent) }
          }
          div(.class("flex justify-between py-2")) {
            dt(.class("text-base-content/70")) { "Sensible Heat Ratio" }
            dd(.class("font-medium")) { NumberView(houseLoad.cooling.sensibleHeatRatio) }
          }
        }
      }
    }
  }
}
