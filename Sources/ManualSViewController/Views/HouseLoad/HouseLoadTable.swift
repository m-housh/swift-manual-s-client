import Elementary
import ManualSModels
import SharedStyleguide

struct HouseLoadView: HTML, Sendable {
  let houseLoad: HouseLoad?

  var body: some HTML<HTMLTag.div> {
    div(.class("stats stats-vertical lg:stats-horizontal shadow w-full")) {
      if let houseLoad {
        Stat("Heating", description: "BTU") { NumberView(houseLoad.heating) }
        Stat("Cooling Total", description: "BTU") {
          NumberView(houseLoad.cooling.total)
        }
        Stat("Cooling Sensible", description: "BTU") {
          NumberView(houseLoad.cooling.sensible)
        }
        Stat("Cooling Latent", description: "BTU") {
          NumberView(houseLoad.cooling.latent)
        }
        Stat("Sensible Heat Ratio") {
          NumberView(houseLoad.cooling.sensibleHeatRatio)
        }
      }
    }
  }
}
