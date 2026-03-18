import Elementary
import ElementaryHTMX
import Foundation
import ManualSModels
import ManualSRouter
import SharedStyleguide

// FIX: This needs to hold onto a list of heating interpolations.
//      and display the forms accordingly.
struct HeatingInterpolationForm: HTML, Identifiable, Sendable {

  static let id = "heatingInterpolationForm"

  let projectID: Project.ID
  let interpolations: [HeatingInterpolation]
  private let tagName = "heatingInterpolationFormTabs"

  var id: String { Self.id }

  private var gasInterpolation: HeatingInterpolation? {
    interpolations.first { $0.boilerOrFurnace != nil }
  }

  private var heatPumpInterpolation: HeatingInterpolation? {
    interpolations.first { $0.heatPump != nil }
  }

  private var electricInterpolation: HeatingInterpolation? {
    interpolations.first { $0.electric != nil }
  }

  private var baseRoute: String {
    ManualSRoute.router.path(for: .projectDetail(projectID, .interpolations(.heating(.index))))
  }

  var body: some HTML {
    Form(
      title: "Heating Interpolation"
    ) {
      p(.class("text-accent italic")) {
        "Complete all sections that apply."
      }

      input(.hidden, .name("projectID"), .value(projectID))

      if let gasInterpolation {
        input(.hidden, .name("boilerOrFurnaceID"), .value(gasInterpolation.id))
      }
      if let electricInterpolation {
        input(.hidden, .name("electricID"), .value(electricInterpolation.id))
      }
      if let heatPumpInterpolation {
        input(.hidden, .name("heatPumpID"), .value(heatPumpInterpolation.id))
      }

      heatPumpFields

      electricFields

      gasFields

      SubmitButton()
        .attributes(.class("btn-block"))
    }
    .fieldsetContentStyle(.vstack(gap: 2))
  }

  private var gasFields: some HTML {
    Fieldset("Gas") {

      label(.class("select w-full")) {
        span(.class("label")) { "Type" }
        Select(
          HeatingInterpolation.Interpolation.BoilerOrFurnace.BoilerOrFurnaceType.allCases,
          value: \.rawValue,
          selected: {
            return gasInterpolation == nil
              ? $0 == .furnace
              : $0 == gasInterpolation?.boilerOrFurnace?.type
          },
          label: \.rawValue.capitalized
        )
        .attributes(
          .name("type"),
          .required
        )
      }

      label(.class("input w-full")) {
        span(.class("label")) { "Input" }
        input(
          .type(.number),
          .name("inputBTU"),
          .value(gasInterpolation?.boilerOrFurnace?.inputBTU),
          .min(0),
          .step(1)
        )
        span(.class("label")) { "BTU/h" }
      }

    }
  }

  private var electricFields: some HTML {
    Fieldset("Electric") {
      label(.class("input w-full")) {
        span(.class("label")) { SVG(.zap) }
        input(
          .type(.number),
          .name("kilowatts"),
          .value(electricInterpolation?.electric),
          .min(0),
          .step(0.1)
        )
        span(.class("label")) { "kw/h" }
      }
    }
  }

  private var heatPumpFields: some HTML {
    Fieldset("Heat Pump - Capacity") {
      label(.class("input w-full")) {
        span(.class("label")) { "@ 47°" }
        input(
          .type(.number),
          .name("capacityAt47"),
          .value(heatPumpInterpolation?.heatPump?.capacityAt47),
          .min(0),
          .step(1)
        )
        span(.class("label")) { "BTU/h" }
      }

      label(.class("input w-full")) {
        span(.class("label")) { "@ 17°" }
        input(
          .type(.number),
          .name("capacityAt17"),
          .value(heatPumpInterpolation?.heatPump?.capacityAt17),
          .min(0),
          .step(1)
        )
        span(.class("label")) { "BTU/h" }
      }
    }
  }
}
