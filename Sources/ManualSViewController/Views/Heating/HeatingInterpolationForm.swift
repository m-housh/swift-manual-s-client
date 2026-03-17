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
  var electricInterpolation: HeatingInterpolation? { interpolations.first { $0.electric != nil } }

  private var baseRoute: String {
    ManualSRoute.router.path(for: .projectDetail(projectID, .interpolations(.heating(.index))))
  }

  var body: some HTML {
    div {
      p(.class("text-accent italic")) {
        "Complete all sections that apply."
      }

      div(.role("tablist"), .class("tabs tabs-lift")) {

        Tab(
          title: "Heat Pump",
          name: tagName,
          checked: interpolations.count == 0 || heatPumpInterpolation != nil
        ) {
          HeatPumpForm(projectID: projectID, interpolation: heatPumpInterpolation)
            .fieldsetContentStyle(.hstack())
        }

        Tab(
          title: "Electric",
          name: tagName,
          checked: electricInterpolation != nil
        ) {
          ElectricForm(projectID: projectID, interpolation: electricInterpolation)
        }
      }
    }
  }

  struct ElectricForm: HTML, Sendable {
    let projectID: Project.ID
    let interpolation: HeatingInterpolation?

    private var route: String {
      ManualSRoute.router.path(for: .projectDetail(projectID, .interpolations(.heating(.index))))
        .appendingPath(interpolation?.id)
    }

    var body: some HTML<HTMLTag.form> {
      Form(
        title: "Heating - Electric",
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

        Fieldset("Proposed KW") {
          label(.class("input w-full")) {
            span(.class("label")) { SVG(.zap) }
            input(
              .type(.number),
              .name("kilowatts"),
              .value(interpolation?.electric),
              .min(0),
              .step(0.1),
              .required
            )
          }
        }

        SubmitButton()
          .attributes(.class("btn-block"))
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
