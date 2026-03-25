import Elementary
import ManualSModels
import SharedStyleguide

struct CoolingInterpolationResponseTable: HTML, Sendable {
  let response: CoolingInterpolation.Response?

  var body: some HTML<HTMLTag.div> {
    div(.class("grid grid-cols-1 lg:grid-cols-3 gap-4")) {
      if let response {
        Card(
          title: "Total",
          flag: response.flaggedCapacities.total,
          interpolatedCapacity: response.interpolatedCapacity.total,
          altitudeAdjustment: response.altitudeDeratings?.total ?? .init(decimal: 1.0),
          excessLatent: nil,
          capacityAtDesign: response.finalCapacityAtDesign.total,
          capacityAsPercentOfDesign: response.capacityAsPercentOfLoad.total,
          undersizingLimit: response.sizingLimits.undersizing.total,
          oversizingLimit: response.sizingLimits.oversizing.total
        )
        Card(
          title: "Sensible",
          flag: response.flaggedCapacities.sensible,
          interpolatedCapacity: response.interpolatedCapacity.sensible,
          altitudeAdjustment: response.altitudeDeratings?.sensible ?? .init(decimal: 1.0),
          excessLatent: nil,
          capacityAtDesign: response.finalCapacityAtDesign.sensible,
          capacityAsPercentOfDesign: response.capacityAsPercentOfLoad.sensible,
          undersizingLimit: response.sizingLimits.undersizing.sensible,
          oversizingLimit: nil
        )
        Card(
          title: "Latent",
          flag: response.flaggedCapacities.latent,
          interpolatedCapacity: response.interpolatedCapacity.latent,
          altitudeAdjustment: response.altitudeDeratings?.latent ?? .init(decimal: 1.0),
          excessLatent: response.excessLatent,
          capacityAtDesign: response.finalCapacityAtDesign.latent,
          capacityAsPercentOfDesign: response.capacityAsPercentOfLoad.latent,
          undersizingLimit: response.sizingLimits.undersizing.latent,
          oversizingLimit: response.sizingLimits.oversizing.latent
        )
      }
    }
  }

  struct Card: HTML, Sendable {
    let title: String
    let flag: FlaggedState
    let interpolatedCapacity: Double
    let altitudeAdjustment: Percent
    let excessLatent: Double?
    let capacityAtDesign: Double
    let capacityAsPercentOfDesign: Percent
    let undersizingLimit: Percent
    let oversizingLimit: Percent?

    var body: some HTML {
      div(.class("border rounded-box shadow-lg p-6")) {
        div(.class("flex justify-between")) {
          h2(.class("text-2xl font-bold label")) { title }
          FlaggedView(flag) {}
        }

        div(.class("grid grid-cols-2 gap-2 justify-items-end mt-6 mx-auto w-fit")) {
          Row("Interpolated Capacity") { NumberView(interpolatedCapacity) }
          Row("Altitude Adjustment") {
            PercentView(altitudeAdjustment == 0 ? .init(decimal: 1.0) : altitudeAdjustment)
          }
          .percentViewStyle(.decimal)
          .percentViewSymbolStyle(.none)
          if let excessLatent {
            Row("Excess Latent") { NumberView(excessLatent) }
          }
          Row("Final Capacity") { NumberView(capacityAtDesign) }
          Row("Percent of Load") { PercentView(capacityAsPercentOfDesign) }
          Row("Sizing Limits") {
            div(.class("flex space-x-1")) {
              PercentView(undersizingLimit)
              span { "-" }
              if let oversizingLimit {
                PercentView(oversizingLimit)
              }
            }
          }
        }
        .percentViewStyle(.default)
        .percentViewSymbolStyle(.default)
      }
    }
  }

  struct Row<Content: HTML>: HTML {
    let label: String
    let _body: Content

    init(_ label: String, @HTMLBuilder body: () -> Content) {
      self.label = label
      self._body = body()
    }

    var body: some HTML {
      span(.class("label")) { label }
      _body
    }
  }
}
