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
  let interpolation: HeatingInterpolation?
  private let tagName = "heatingInterpolationFormTabs"

  var id: String { Self.id }

  private var route: String {
    ManualSRoute.router.path(for: .projectDetail(projectID, .interpolations(.heating(.index))))
      .appendingPath(interpolation?.id)
  }

  var body: some HTML {
    Form(
      title: "Heating",
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

      div(.role("tablist"), .class("tabs tabs-lift")) {
        Tab(
          title: "Heat Pump",
          name: tagName,
          checked: interpolation == nil || interpolation?.heatPump != nil
        ) {
          heatPumpFields.fieldsetContentStyle(.hstack())
        }

        Tab(
          title: "Gas",
          name: tagName,
          checked: interpolation?.boilerOrFurnace != nil
        ) {
          boilerFields
        }

        Tab(
          title: "Electric",
          name: tagName,
          checked: interpolation?.electric != nil
        ) {
          electricFields
        }

      }

      SubmitButton()
        .attributes(.class("btn-block mt-6"), .type(.submit))
    }
  }

  @HTMLBuilder
  private var heatPumpFields: some HTML {
    Fieldset("Output") {
      label(.class("input w-full")) {
        span(.class("label")) { "@ 47°" }
        input(
          .type(.number),
          .name("capacityAt47"),
          .value(interpolation?.heatPump?.capacityAt47),
          .min(0),
          .step(1),
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
        )
      }
    }
  }

  @HTMLBuilder
  private var boilerFields: some HTML {
    Fieldset("Input") {
      label(.class("input w-full")) {
        span(.class("label")) { SVG(.flame) }
        input(
          .type(.number),
          .name("inputBTU"),
          .value(interpolation?.boilerOrFurnace?.inputBTU),
          .min(0),
          .step(1),
        )
        span(.class("label")) { "BTU/h" }
      }
    }

    Fieldset("Equipment Type") {
      label(.class("select w-full")) {
        span(.class("label")) { "Type" }
        Select(
          HeatingInterpolation.Interpolation.BoilerOrFurnace.BoilerOrFurnaceType.allCases,
          value: \.rawValue,
          selected: {
            interpolation == nil
              ? $0 == .furnace
              : $0 == interpolation?.boilerOrFurnace?.type
          },
          label: \.title
        )
        .attributes(
          .name("type"),
        )
      }
    }
  }

  @HTMLBuilder
  private var electricFields: some HTML {
    Fieldset("KW") {
      label(.class("input w-full")) {
        span(.class("label")) { SVG(.zap) }
        input(
          .type(.number),
          .name("kilowatts"),
          .value(interpolation?.electric),
          .min(0),
          .step(0.1)
        )
        span(.class("label")) { "kw/h" }
      }
    }
  }
}
