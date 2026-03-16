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

  var heatPumpInterpolation: HeatingInterpolation? { interpolations.first { $0.heatPump != nil } }

  var body: some HTML {

    div(.role("tablist"), .class("tabs tabs-lift")) {
      Tab(
        title: "Heat Pump",
        name: tagName,
        checked: interpolations.count == 0 || heatPumpInterpolation != nil
      ) {
        HeatPumpForm(projectID: projectID, interpolation: heatPumpInterpolation)
          .fieldsetContentStyle(.hstack())
      }
    }
  }

  // @HTMLBuilder
  // private var boilerFields: some HTML {
  //   Fieldset("Input") {
  //     label(.class("input w-full")) {
  //       span(.class("label")) { SVG(.flame) }
  //       input(
  //         .type(.number),
  //         .name("inputBTU"),
  //         .value(interpolation?.boilerOrFurnace?.inputBTU),
  //         .min(0),
  //         .step(1),
  //       )
  //       span(.class("label")) { "BTU/h" }
  //     }
  //   }
  //
  //   Fieldset("Equipment Type") {
  //     label(.class("select w-full")) {
  //       span(.class("label")) { "Type" }
  //       Select(
  //         HeatingInterpolation.Interpolation.BoilerOrFurnace.BoilerOrFurnaceType.allCases,
  //         value: \.rawValue,
  //         selected: {
  //           interpolation == nil
  //             ? $0 == .furnace
  //             : $0 == interpolation?.boilerOrFurnace?.type
  //         },
  //         label: \.title
  //       )
  //       .attributes(
  //         .name("type"),
  //       )
  //     }
  //   }
  // }
  //
  // @HTMLBuilder
  // private var electricFields: some HTML {
  //   Fieldset("KW") {
  //     label(.class("input w-full")) {
  //       span(.class("label")) { SVG(.zap) }
  //       input(
  //         .type(.number),
  //         .name("kilowatts"),
  //         .value(interpolation?.electric),
  //         .min(0),
  //         .step(0.1)
  //       )
  //       span(.class("label")) { "kw/h" }
  //     }
  //   }
  // }
}
