import Elementary
import Foundation
import ManualSModels
import ManualSRouter
import SharedModels
import SharedStyleguide

struct OneWayForm: HTML, Sendable {

  let style: Style
  let outdoorDesignTemperature: Double
  let projectID: Project.ID
  let interpolationID: CoolingInterpolation.ID?
  let designAirflow: Int?
  let manufacturersAdjustments: CoolingCapacityAdjustment?
  let oneWayIndoor: CoolingInterpolation.Interpolation.OneWayIndoor?
  let oneWayOutdoor: CoolingInterpolation.Interpolation.OneWayOutdoor?

  init(
    style: OneWayForm.Style,
    outdoorDesignTemperature: Double,
    projectID: Project.ID,
    interpolationID: CoolingInterpolation.ID? = nil,
    designAirflow: Int? = nil,
    manufacturersAdjustments: CoolingCapacityAdjustment? = nil,
    oneWayIndoor: CoolingInterpolation.Interpolation.OneWayIndoor? = nil,
    oneWayOutdoor: CoolingInterpolation.Interpolation.OneWayOutdoor? = nil
  ) {
    self.style = style
    self.outdoorDesignTemperature = outdoorDesignTemperature
    self.projectID = projectID
    self.interpolationID = interpolationID
    self.designAirflow = designAirflow
    self.manufacturersAdjustments = manufacturersAdjustments
    self.oneWayIndoor = oneWayIndoor
    self.oneWayOutdoor = oneWayOutdoor
  }

  private var route: String {
    ManualSRoute.router.path(for: .projectDetail(projectID, .interpolations(.cooling(.index))))
      .appendingPath(interpolationID)
  }

  private var belowWetBulb: Int {
    guard style == .indoor else { return 63 }
    return 62
  }

  private var belowTemp: Double {
    guard style == .outdoor else { return outdoorDesignTemperature }
    let evenDecimal = floor(outdoorDesignTemperature / 10)
    return (evenDecimal - 0.5) * 10.0
  }

  private var belowCapacity: CoolingCapacity? {
    switch style {
    case .indoor: return oneWayIndoor?.belowDesign.capacity
    case .outdoor: return oneWayOutdoor?.belowDesign.capacity
    }
  }

  private var aboveWetBulb: Int {
    guard style == .indoor else { return 63 }
    return 67
  }

  private var aboveTemp: Double {
    guard style == .outdoor else { return outdoorDesignTemperature }
    let evenDecimal = floor(outdoorDesignTemperature / 10)
    return (evenDecimal + 0.5) * 10.0
  }

  private var aboveCapacity: CoolingCapacity? {
    switch style {
    case .indoor: return oneWayIndoor?.aboveDesign.capacity
    case .outdoor: return oneWayOutdoor?.aboveDesign.capacity
    }
  }

  var body: some HTML<HTMLTag.form> {
    Form(
      title: "One Way - \(style.rawValue.capitalized)",
      interpolationID == nil
        ? .hx.post(route)
        : .hx.patch(route),
      .hx.target(id: ProjectDetailsView.Section.id(.coolingInterpolation())),
      .hx.swap(.outerHTML)
    ) {

      input(.hidden, .name("projectID"), .value(projectID))

      DesignAirflowFieldset(designAirflow: designAirflow)

      Fieldset("Below") {
        p(.class("text-accent text-sm italic pb-6")) {
          style.description(.below)
        }
        label(.class("input w-full")) {
          span(.class("label")) { SVG(.thermometerSun) }
          input(
            .type(.number),
            .name("belowDesignOutdoorTemperature"),
            .value(belowTemp),
            .min(0),
            .step(1),
          )
          .attributes(.disabled, when: style == .indoor)
          .attributes(.required, when: style == .outdoor)

          span(.class("label")) { "Outdoor Temp." }
        }

        label(.class("input w-full")) {
          span(.class("label")) { SVG(.droplets) }
          input(
            .type(.number),
            .value(belowWetBulb),
            .name("belowWetBulb"),
            .min(0),
            .step(1),
          )
          .attributes(.disabled, when: style == .outdoor)
          .attributes(.required, when: style == .indoor)

          span(.class("label")) { "Return Wet Bulb" }
        }

        TotalSensibleFieldset(.coolingCapacity(belowCapacity), namePrefix: "below")
          .fieldsetStyle(.plain)
      }

      Fieldset("Above") {
        p(.class("text-accent text-sm italic pb-6")) {
          style.description(.above)
        }

        label(.class("input w-full")) {
          span(.class("label")) { SVG(.thermometerSun) }
          input(
            .type(.number),
            .name("aboveDesignOutdoorTemperature"),
            .value(aboveTemp),
            .min(0),
            .step(1),
          )
          .attributes(.disabled, when: style == .indoor)
          .attributes(.required, when: style == .outdoor)

          span(.class("label")) { "Outdoor Temp." }
        }

        label(.class("input w-full")) {
          span(.class("label")) { SVG(.droplets) }
          input(
            .type(.number),
            .value(aboveWetBulb),
            .name("aboveWetBulb"),
            .min(0),
            .step(1),
          )
          .attributes(.disabled, when: style == .outdoor)
          .attributes(.required, when: style == .indoor)

          span(.class("label")) { "Return Wet Bulb" }
        }

        TotalSensibleFieldset(.coolingCapacity(aboveCapacity), namePrefix: "above")
          .fieldsetStyle(.plain)
      }

      TotalSensibleFieldset(.manufacturersAdjustments(manufacturersAdjustments))

      SubmitButton()
        .attributes(.class("btn-block my-6"))
    }
    .fieldsetStyle(.roundedBox)
  }
}

extension OneWayForm {

  enum Style: String, Sendable {
    case indoor
    case outdoor

    enum DescriptionType: String, Sendable {
      case above
      case below
    }

    private var descriptionKey: String {
      switch self {
      case .indoor: return "wet bulb"
      case .outdoor: return "temperature"
      }
    }

    func description(_ type: DescriptionType) -> String {
      """
      The closest manufacturer's specification \(type.rawValue) the \(rawValue) design \(descriptionKey).
      """
    }
  }
}
