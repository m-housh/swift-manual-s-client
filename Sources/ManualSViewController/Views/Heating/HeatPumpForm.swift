import Elementary
import ElementaryHTMX
import Foundation
import ManualSModels
import ManualSRouter
import SharedModels
import SharedStyleguide

struct HeatPumpForm2: HTML, Identifiable, Sendable {

  let projectID: Project.ID
  let index: Int
  let interpolation: HeatingInterpolation?

  var id: String { "heatPumpHeatingForm_\(index)" }

  private var route: String {
    ManualSRoute.router.path(for: .projectDetail(projectID, .interpolations(.heating(.index))))
      .appendingPath(interpolation?.id)
  }

  var body: some HTML<HTMLTag.form> {
    Form(
      title: "Heating - Heat Pump",
      interpolation == nil
        ? .hx.post(route)
        : .hx.patch(route),
      .hx.target(id: ProjectDetailsView.Section.id(.heatingInterpolation())),
      .hx.swap(.outerHTML)
    ) {
      input(.hidden, .name("projectID"), .value(projectID))

      if let interpolation {
        input(.hidden, .name("id"), .value(interpolation.id))
      }

      Fieldset("Output") {
        label(.class("input w-full")) {
          span(.class("label")) { "@ 47°" }
          input(
            .type(.number),
            .name("capacityAt47"),
            .value(interpolation?.heatPump?.capacityAt47),
            .min(0),
            .step(1),
            .required
          )
        }

        label(.class("input w-full")) {
          span(.class("label")) { "@ 17°" }
          input(
            .type(.number),
            .name("capacityAt17"),
            .value(interpolation?.heatPump?.capacityAt17),
            .min(0),
            .step(1),
            .required
          )
        }
      }

      SubmitButton()
        .attributes(.class("btn-block"))
    }
  }
}

struct HeatPumpForm: HTML, Identifiable, Sendable {

  static let id = "heatPumpForm"
  var id: String { Self.id }

  let altitudeAdjustment: Percent?
  let capacity: HeatPumpCapacity?
  let proposedKW: Int?
  let requiredKW: Double

  var body: some HTML<HTMLTag.form> {
    Form(
      title: "Heat Pump - Heating"
    ) {
      fieldset(.class("fieldset")) {
        legend(.class("fieldset-legend")) { "Output" }

        label(.class("input w-full")) {
          span(.class("label")) { "@ 47°" }
          input(
            .type(.number),
            .name("capacityAt47"),
            .value(capacity?.capacityAt47),
            .min(0),
            .step(1),
            .required
          )
        }

        label(.class("input w-full")) {
          span(.class("label")) { "@ 17°" }
          input(
            .type(.number),
            .name("capacityAt17"),
            .value(capacity?.capacityAt17),
            .min(0),
            .step(1),
            .required
          )
        }
      }

      // fieldset(.class("fieldset")) {
      //   legend(.class("fieldset-legend")) { "Altitude Adjustment" }
      //
      //   input(
      //     .type(.range),
      //     .id("altitudeAdjustmentSlider"),
      //     // .name("altitudeAdjustment"),
      //     .value(altitudeAdjustment?.rawValue ?? 100),
      //     .min(50),
      //     .max(100),
      //     .step(1),
      //     .on(.change, "syncInputs('altitudeAdjustmentInput', 'altitudeAdjustmentSlider');")
      //   )
      //
      //   label(.class("input w-full")) {
      //     input(
      //       .type(.number),
      //       .id("altitudeAdjustmentInput"),
      //       .name("altitudeAdjustment"),
      //       .value(altitudeAdjustment?.rawValue ?? 100),
      //       .min(0),
      //       .max(100),
      //       .step(1),
      //       .on(.change, "syncInputs('altitudeAdjustmentSlider', 'altitudeAdjustmentInput');")
      //     )
      //     span(.class("label")) { SVG(.percent) }
      //   }
      //   // p(.class("text-sm italic")) { "Optional" }
      // }

      fieldset(.class("fieldset")) {
        div(.class("flex justify-between text-md")) {
          // legend(.class("fieldset-legend justify-between")) {
          div(.class("font-bold")) {
            span { "Electric Heat" }
          }

          div(.class("flex justify-end space-x-2")) {
            span(.class("font-bold")) { "Required KW:" }
            NumberView(requiredKW)
              .attributes(.class("italic"))
          }
        }

        label(.class("input w-full")) {
          span(.class("label")) { SVG(.zap) }
          input(
            .type(.number),
            .name("proposedKW"),
            .value(proposedKW),
            .placeholder("Proposed KW"),
            .min(0),
            .step(1)
          )
        }
        div {
          span(.class("text-sm italic")) { "Optional" }
        }
      }

      SubmitButton()
        .attributes(.class("btn-block"))
    }
  }
}
