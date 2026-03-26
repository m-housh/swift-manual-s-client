import Elementary
import ManualSModels
import SharedStyleguide

struct CoolingInterpolationResponseTable: HTML, Sendable {
  let response: CoolingInterpolation.Response?

  var body: some HTML {
    if let response {
      div(.class("space-y-6")) {
        // Status Summary Row
        div(.class("flex items-center gap-4 mb-4")) {
          span(.class("text-lg font-semibold")) { "Overall Status:" }
          OverallStatusBadge(response: response)
        }

        // Main Results Table
        Table {
          thead(.class("bg-base-300 text-base-content")) {
            tr {
              th { "Capacity Type" }
              th(.class("text-right")) { "Final Capacity" }
              th(.class("text-right")) { "% of Load" }
              th(.class("text-center")) { "Status" }
            }
          }
          tbody {
            // Total Capacity Row
            CapacityRow(
              label: "Total",
              flag: response.flaggedCapacities.total,
              interpolated: response.interpolatedCapacity.total,
              altitudeAdj: response.altitudeDeratings?.total ?? .init(decimal: 1.0),
              excessLatent: nil,
              finalCapacity: response.finalCapacityAtDesign.total,
              percentOfLoad: response.capacityAsPercentOfLoad.total,
              undersizingLimit: response.sizingLimits.undersizing.total,
              oversizingLimit: response.sizingLimits.oversizing.total
            )

            // Sensible Capacity Row
            CapacityRow(
              label: "Sensible",
              flag: response.flaggedCapacities.sensible,
              interpolated: response.interpolatedCapacity.sensible,
              altitudeAdj: response.altitudeDeratings?.sensible ?? .init(decimal: 1.0),
              excessLatent: nil,
              finalCapacity: response.finalCapacityAtDesign.sensible,
              percentOfLoad: response.capacityAsPercentOfLoad.sensible,
              undersizingLimit: response.sizingLimits.undersizing.sensible,
              oversizingLimit: nil
            )

            // Latent Capacity Row
            CapacityRow(
              label: "Latent",
              flag: response.flaggedCapacities.latent,
              interpolated: response.interpolatedCapacity.latent,
              altitudeAdj: response.altitudeDeratings?.latent ?? .init(decimal: 1.0),
              excessLatent: response.excessLatent,
              finalCapacity: response.finalCapacityAtDesign.latent,
              percentOfLoad: response.capacityAsPercentOfLoad.latent,
              undersizingLimit: response.sizingLimits.undersizing.latent,
              oversizingLimit: response.sizingLimits.oversizing.latent
            )
          }
        }
        .attributes(.class("table-sm"))
      }
    }
  }
}

struct OverallStatusBadge: HTML {
  let response: CoolingInterpolation.Response

  var body: some HTML {
    let allPass = response.flaggedCapacities.total == .success
      && response.flaggedCapacities.sensible == .success
      && response.flaggedCapacities.latent == .success

    if allPass {
      span(.class("badge badge-success badge-lg")) {
        SVG(.check)
        "Meets Requirements"
      }
    } else {
      span(.class("badge badge-error badge-lg")) {
        SVG(.x)
        "Does Not Meet Requirements"
      }
    }
  }
}

struct CapacityRow: HTML {
  let label: String
  let flag: FlaggedState
  let interpolated: Double
  let altitudeAdj: Percent
  let excessLatent: Double?
  let finalCapacity: Double
  let percentOfLoad: Percent
  let undersizingLimit: Percent
  let oversizingLimit: Percent?

  var body: some HTML<HTMLTag.tr> {
    tr {
      td {
        details(.class("cursor-pointer group")) {
          summary(.class("font-medium list-none flex items-center gap-1")) {
            span(.class("transition-transform duration-200 group-open:rotate-90")) {
              SVG(.chevronRight)
            }
            label
          }
          div(.class("mt-2 ml-5 space-y-1 text-sm text-base-content/70")) {
            div(.class("flex justify-between")) {
              span { "Interpolated Capacity" }
              span(.class("font-mono")) { NumberView(interpolated) }
            }
            div(.class("flex justify-between")) {
              span { "Altitude Adjustment" }
              span(.class("font-mono")) {
                PercentView(
                  altitudeAdj == 0 ? .init(decimal: 1.0) : altitudeAdj
                )
              }
            }
            .percentViewStyle(.decimal)
            .percentViewSymbolStyle(.none)
            if let excessLatent {
              div(.class("flex justify-between")) {
                span { "Excess Latent" }
                span(.class("font-mono")) { NumberView(excessLatent) }
              }
            }
            div(.class("flex justify-between")) {
              span { "Sizing Limits" }
              span(.class("font-mono flex gap-1")) {
                PercentView(undersizingLimit)
                " - "
                if let oversizingLimit {
                  PercentView(oversizingLimit)
                }
              }
            }
            .percentViewStyle(.hstack(gap: 1))
            .percentViewSymbolStyle(.default)
          }
        }
      }
      td(.class("text-right font-mono font-semibold align-top")) {
        NumberView(finalCapacity)
      }
      td(.class("text-right font-mono align-top")) {
        PercentView(percentOfLoad)
      }
      .percentViewStyle(.hstack(gap: 2), .end)
      .percentViewSymbolStyle(.default)
      td(.class("text-center align-top")) {
        FlaggedBadge(state: flag)
      }
    }
    .attributes(.class("hover"))
  }
}

struct FlaggedBadge: HTML {
  let state: FlaggedState

  var body: some HTML {
    switch state {
    case .success:
      span(.class("badge badge-success badge-sm")) { "Pass" }
    case .failure:
      span(.class("badge badge-error badge-sm")) { "Fail" }
    }
  }
}
