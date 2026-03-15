import CasePaths
import CasePathsCore
import Elementary
import ElementaryHTMX
import ManualSModels
import ManualSRouter

import SharedStyleguide

struct CoolingInterpolationForm: HTML, Identifiable, Sendable {

  static let id = "coolingInterpolationForm"

  var id: String { Self.id }

  let projectID: Project.ID
  let designInfo: DesignInfo?
  let interpolation: CoolingInterpolation?
  private let tagName = "coolingInterpolationTabs"

  var body: some HTML {
    FormTitle { "Interpolation" }

    div(.role("tablist"), .class("tabs tabs-lift")) {
      Tab(
        title: "None",
        name: tagName,
        checked: interpolation?.noInterpolation != nil || interpolation == nil
      ) {
        NoInterpolationForm(
          projectID: projectID,
          interpolation: interpolation
        )
      }

      Tab(
        title: "One Way - Indoor",
        name: tagName,
        checked: interpolation?.oneWayIndoor != nil
      ) {
        OneWayForm(
          style: .indoor,
          outdoorDesignTemperature: Double(designInfo?.summerOutdoorTemperature ?? 90),
          projectID: projectID,
          interpolation: interpolation
        )
      }

      Tab(
        title: "One Way - Outdoor",
        name: tagName,
        checked: interpolation?.oneWayOutdoor != nil
      ) {
        OneWayForm(
          style: .outdoor,
          outdoorDesignTemperature: Double(designInfo?.summerOutdoorTemperature ?? 90),
          projectID: projectID,
          interpolation: interpolation
        )
      }

      Tab(
        title: "Two Way",
        name: tagName,
        checked: interpolation?.twoWay != nil
      ) {
        TwoWayForm(
          projectID: projectID,
          outdoorDesignTemperature: Double(designInfo?.summerOutdoorTemperature ?? 90),
          interpolation: interpolation
        )

      }
    }
  }

  // func tab(title: String, name: String = "myTabs", checked: Bool = false) -> some HTML {
  //   input(
  //     .type(.radio),
  //     .name(name), .class("tab"),
  //     .init(name: "aria-label", value: title)
  //   )
  //   .attributes(.checked, when: checked)
  // }
  //
  // func tabContent<C: HTML>(@HTMLBuilder content: () -> C) -> some HTML {
  //   div(.class("tab-content border-base-300 p-6")) {
  //     content()
  //   }
  // }

}
