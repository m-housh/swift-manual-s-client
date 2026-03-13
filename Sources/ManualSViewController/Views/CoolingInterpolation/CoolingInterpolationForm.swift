import CasePaths
import CasePathsCore
import Elementary
import ElementaryHTMX
import ManualSModels
import SharedModels
import SharedStyleguide

struct CoolingInterpolationForm: HTML, Identifiable, Sendable {

  static let id = "coolingInterpolationForm"

  var id: String { Self.id }

  let projectID: Project.ID
  let designInfo: DesignInfo?
  let interpolation: CoolingInterpolation?

  var body: some HTML {
    FormTitle { "Interpolation" }

    div(.role("tablist"), .class("tabs tabs-lift")) {
      tab(title: "None", checked: noInterpolation != nil)
      tabContent {
        NoInterpolationForm(
          projectID: projectID,
          interpolationID: interpolation?.id,
          designAirflow: interpolation?.designAirflow,
          capacity: noInterpolation,
          manufacturersAdjustments: interpolation?.manufacturersAdjustments
        )
      }

      tab(title: "One Way - Indoor", checked: oneWayIndoor != nil)
      tabContent {
        OneWayForm(
          style: .indoor,
          outdoorDesignTemperature: Double(designInfo?.summerOutdoorTemperature ?? 90),
          projectID: projectID,
          interpolationID: interpolation?.id,
          designAirflow: interpolation?.designAirflow,
          manufacturersAdjustments: interpolation?.manufacturersAdjustments,
          oneWayIndoor: oneWayIndoor
        )
      }

      tab(title: "One Way - Outdoor", checked: oneWayOutdoor != nil)
      tabContent {
        OneWayForm(
          style: .outdoor,
          outdoorDesignTemperature: Double(designInfo?.summerOutdoorTemperature ?? 90),
          projectID: projectID,
          interpolationID: interpolation?.id,
          designAirflow: interpolation?.designAirflow,
          manufacturersAdjustments: interpolation?.manufacturersAdjustments,
          oneWayOutdoor: oneWayOutdoor
        )
      }

      tab(title: "Two Way", checked: twoWay != nil)
      tabContent {
        TwoWayForm(
          projectID: projectID,
          outdoorDesignTemperature: Double(designInfo?.summerOutdoorTemperature ?? 90),
          interpolationID: interpolation?.id,
          designAirflow: interpolation?.designAirflow,
          manufacturersAdjustments: interpolation?.manufacturersAdjustments,
          twoWay: twoWay
        )

      }
    }
  }

  func tab(title: String, name: String = "myTabs", checked: Bool = false) -> some HTML {
    input(
      .type(.radio),
      .name(name), .class("tab"),
      .init(name: "aria-label", value: title)
    )
    .attributes(.checked, when: checked)
  }

  func tabContent<C: HTML>(@HTMLBuilder content: () -> C) -> some HTML {
    div(.class("tab-content border-base-300 p-6")) {
      content()
    }
  }

  private var noInterpolation: CoolingCapacity? {
    interpolation?[dynamicMember: \.noInterpolation]
  }

  private var oneWayIndoor: CoolingInterpolation.Interpolation.OneWayIndoor? {
    interpolation?[dynamicMember: \.oneWayIndoor]
  }

  private var oneWayOutdoor: CoolingInterpolation.Interpolation.OneWayOutdoor? {
    interpolation?[dynamicMember: \.oneWayOutdoor]
  }

  private var twoWay: CoolingInterpolation.Interpolation.TwoWay? {
    interpolation?[dynamicMember: \.twoWay]
  }

}
