import Elementary
import ElementaryHTMX
import Foundation
import ManualSModels
import SharedModels
import SharedStyleguide

struct HeatingInterpolationForm: HTML, Identifiable, Sendable {

  let projectID: Project.ID
  let interpolation: HeatingInterpolation?
  private let tagName = "heatingInterpolationFormTabs"

  var id: String {
    "heatingInterpolationForm"
  }

  var body: some HTML {
    div(.role("tablist"), .class("tabs tabs-lift")) {
      Tab(
        title: "Heat Pump",
        name: tagName,
        checked: interpolation == nil || interpolation?.heatPump != nil
      ) {
        HeatPumpForm2(
          projectID: projectID,
          index: 0,  // FIX: pass parent index in.
          interpolation: interpolation
        )
        .fieldsetContentStyle(.hstack())
        // HeatPumpForm(
        //   altitudeAdjustment: nil,
        //   capacity: interpolation?.heatPump,
        //   proposedKW: interpolation?.electric,
        //   requiredKW: 14.55  // FIX: Pass in required kw when creating the form.
        // )
      }

      Tab(
        title: "Boiler / Furnace",
        name: tagName,
        checked: interpolation?.boilerOrFurnace != nil
      ) {
        // FIX: Implement
      }

      // TODO: Electric only ??
    }
  }
}
