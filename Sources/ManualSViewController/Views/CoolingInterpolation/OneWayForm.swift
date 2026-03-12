import Elementary
import Foundation
import SharedModels
import SharedStyleguide

struct OneWayForm: HTML, Sendable {

  let style: Style
  let outdoorDesignTemperature: Double

  private var belowWetBulb: Int {
    guard style == .indoor else { return 63 }
    return 62
  }

  private var belowTemp: Double {
    guard style == .outdoor else { return outdoorDesignTemperature }
    let evenDecimal = floor(outdoorDesignTemperature / 10)
    return (evenDecimal - 0.5) * 10.0
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

  var body: some HTML<HTMLTag.form> {
    form(.class("space-y-4")) {
      FormTitle { "One Way - \(style.rawValue.capitalized)" }

      Fieldset("Below") {
        p(.class("text-accent text-sm italic pb-6")) {
          style.description(.below)
        }
        label(.class("input w-full")) {
          span(.class("label")) { SVG(.thermometerSun) }
          input(
            .type(.number),
            .name("belowOutdoorTemperature"),
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

        CoolingContainerFieldset(capacity: nil, namePrefix: "below")
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
            .name("aboveOutdoorTemperature"),
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

        CoolingContainerFieldset(capacity: nil, namePrefix: "above")
          .fieldsetStyle(.plain)
      }

      ManufacturersAdjustmentFieldset(adjustments: nil)

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
