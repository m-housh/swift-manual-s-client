import Elementary
import ManualSModels
import SharedStyleguide

struct DesignAirflowFieldset: HTML, Sendable {
  let designAirflow: Int?

  var body: some HTML<HTMLTag.fieldset> {
    Fieldset("Design Airflow") {
      label(.class("input w-full")) {
        span(.class("label")) { SVG(.wind) }
        input(
          .type(.number),
          .name("designAirflow"),
          .value(designAirflow),
          .min(0),
          .step(1),
          .required,
        )
      }
    }
  }
}
