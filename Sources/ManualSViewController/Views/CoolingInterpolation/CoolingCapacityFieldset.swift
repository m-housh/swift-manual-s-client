import Elementary
import ManualSModels
import SharedStyleguide
import Tagged

struct CoolingCapacityFieldset: HTML, Sendable {

  let capacity: CoolingCapacity?
  let title: String = "Cooling Capacity"

  var body: some HTML<HTMLTag.fieldset> {
    fieldset {
      legend(.class("fieldset-legend")) { title }

      div(.class("flex gap-4")) {
        label(.class("input w-full")) {
          span(.class("label")) { "Total" }
          input(
            .type(.number),
            .name("coolingTotal"),
            .value(capacity?.total),
            .min(0),
            .step(1),
            .required
          )
        }

        label(.class("input w-full")) {
          span(.class("label")) { "Sensible" }
          input(
            .type(.number),
            .name("coolingSensible"),
            .value(capacity?.sensible),
            .min(0),
            .step(1),
            .required
          )
        }
      }
      // .attributes(.class("flex gap-4"), when: style == .horizontal)
    }
  }
}
