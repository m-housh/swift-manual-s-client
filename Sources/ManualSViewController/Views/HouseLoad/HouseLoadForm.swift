import Elementary
import ElementaryHTMX
import ManualSModels
import SharedStyleguide

struct HouseLoadForm: HTML, Identifiable, Sendable {
  static let id = "houseLoadForm"

  let houseLoad: HouseLoad?
  var id: String { Self.id }

  var body: some HTML<HTMLTag.form> {
    Form(title: "House Load", .class("space-y-4")) {

      if let houseLoad {
        input(.hidden, .name("id"), .value(houseLoad.id))
      }

      fieldset(.class("fieldset")) {
        legend(.class("fieldset-legend")) { "Heating" }
        label(.class("input w-full")) {
          span(.class("label")) { SVG(.flame) }
          input(
            .type(.number),
            .name("heating"),
            .value(houseLoad?.heating),
            .min(0),
            .step(1),
            .required
          )
        }
      }

      fieldset(.class("fieldset")) {
        legend(.class("fieldset-legend")) { "Cooling" }

        label(.class("input w-full")) {
          span(.class("label")) { SVG(.leaf) }
          input(
            .type(.number),
            .name("coolingTotal"),
            .value(houseLoad?.cooling.total),
            .min(0),
            .step(1),
            .required
          )
          span(.class("label min-w-[5rem]")) { "Total" }
        }
        label(.class("input w-full")) {
          span(.class("label")) { SVG(.thermometerSun) }
          input(
            .type(.number),
            .name("coolingSensible"),
            .value(houseLoad?.cooling.sensible),
            .min(0),
            .step(1),
            .required
          )
          span(.class("label min-w-[5rem]")) { "Sensible" }
        }
      }

      SubmitButton()
        .attributes(.class("btn-block mt-6"))
    }
  }
}
