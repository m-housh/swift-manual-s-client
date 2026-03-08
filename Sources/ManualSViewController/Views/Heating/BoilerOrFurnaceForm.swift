import Elementary
import ElementaryHTMX
import ManualSModels
import SharedStyleguide

struct BoilerOrFurnaceForm: HTML, Identifiable, Sendable {

  static let id = "boilerOrFurnaceForm"

  var id: String { Self.id }
  let altitudeAdjustment: Percent?
  let inputBTU: Double?
  let interpolationType: InterpolationType

  var body: some HTML<HTMLTag.form> {
    form {
      FormTitle { "\(interpolationType.title) - Heating" }

      fieldset(.class("fieldset")) {
        legend(.class("fieldset-legend")) { "Input BTU" }
        label(.class("input w-full")) {
          span(.class("label")) { SVG(.flame) }
          input(
            .type(.number),
            .name("inputBTU"),
            .value(inputBTU),
            .min(0),
            .step(1),
            .required
          )
        }
      }
      fieldset(.class("fieldset")) {
        legend(.class("fieldset-legend")) { "Altitude Adjustment" }
        label(.class("input w-full")) {
          span(.class("label")) { SVG(.percent) }
          input(
            .type(.number),
            .name("altitudeAdjustment"),
            .value(altitudeAdjustment?.decimal ?? 1.0),
            .min(0),
            .max(1.0),
            .step(0.1),
          )
        }
        p(.class("text-sm italic")) { "Optional" }
      }

      SubmitButton()
        .attributes(.class("btn-block mt-6"))
    }
  }

  enum InterpolationType: String, CaseIterable {
    case boiler
    case furnace

    var title: String { rawValue.capitalized }
  }
}
