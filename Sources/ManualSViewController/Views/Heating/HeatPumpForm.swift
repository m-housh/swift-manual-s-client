import Elementary
import ElementaryHTMX
import ManualSModels
import SharedStyleguide

struct HeatPumpForm: HTML, Identifiable, Sendable {

  static let id = "heatPumpForm"
  var id: String { Self.id }
  let capacity: HeatPumpCapacity?

  var body: some HTML<HTMLTag.form> {
    Form(
      title: "Heat Pump - Heating"
    ) {
      fieldset(.class("fieldset")) {
        legend(.class("fieldset-legend")) { "Output" }

        label(.class("input w-full")) {
          span(.class("label")) { "@ 47°" }
          input(
            .type(.number),
            .name("capacityAt47"),
            .value(capacity?.capacityAt47),
            .min(0),
            .step(1),
            .required
          )
        }

        label(.class("input w-full")) {
          span(.class("label")) { "@ 17°" }
          input(
            .type(.number),
            .name("capacityAt17"),
            .value(capacity?.capacityAt17),
            .min(0),
            .step(1),
            .required
          )
        }
      }
    }
  }
}
