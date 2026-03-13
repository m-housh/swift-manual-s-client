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
      tab(title: "None", checked: noInterpolationChecked)
      tabContent {
        NoInterpolationForm(
          projectID: projectID,
          interpolationID: interpolation?.id,
          designAirflow: interpolation?.designAirflow,
          capacity: noInterpolationCapacity,
          manufacturersAdjustments: interpolation?.manufacturersAdjustments
        )
      }

      tab(title: "One Way - Indoor", checked: oneWayIndoorChecked)
      tabContent {
        // FIX:
        OneWayForm(
          style: .indoor,
          outdoorDesignTemperature: Double(designInfo?.summerOutdoorTemperature ?? 90)
        )
      }

      tab(title: "One Way - Outdoor", checked: oneWayOutdoorChecked)
      tabContent {
        // FIX:
        OneWayForm(
          style: .outdoor,
          outdoorDesignTemperature: Double(designInfo?.summerOutdoorTemperature ?? 90)
        )
      }

      tab(title: "Two Way", checked: twoWayChecked)
      tabContent {
        // FIX:
        span(.class("text-error font-bold")) { "Two Way: Implement Me!!!" }
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

  private var noInterpolationCapacity: CoolingCapacity? {
    guard let interpolation,
      case .noInterpolation(let capacity) = interpolation.interpolation
    else { return nil }
    return capacity
  }

  private var noInterpolationChecked: Bool {
    if let interpolation {
      if case .noInterpolation(_) = interpolation.interpolation {
        return true
      }
      return false
    }
    return true
  }

  private var oneWayIndoorChecked: Bool {
    if let interpolation {
      if case .oneWayIndoor(_) = interpolation.interpolation {
        return true
      }
    }
    return false
  }

  private var oneWayOutdoorChecked: Bool {
    if let interpolation {
      if case .oneWayOutdoor(_) = interpolation.interpolation {
        return true
      }
    }
    return false
  }

  private var twoWayChecked: Bool {
    if let interpolation {
      if case .twoWay(_) = interpolation.interpolation {
        return true
      }
    }
    return false
  }
}
