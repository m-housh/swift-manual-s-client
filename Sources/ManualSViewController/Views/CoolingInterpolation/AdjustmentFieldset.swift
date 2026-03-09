import Elementary
import ManualSModels
import SharedStyleguide
import Tagged

struct AltitudeAdjustmentFieldset: HTML, Sendable {

  let adjustments: CoolingCapacityAdjustment?

  var body: some HTML<HTMLTag.fieldset> {
    _AdjustmentFieldset(
      "Altitude Adjustments",
      adjustments:
        adjustments,
      fieldNamePrefix: "altitudeAdjustment"
    )
  }
}

struct ManufacturersAdjustmentFieldset: HTML, Sendable {

  let adjustments: CoolingCapacityAdjustment?

  var body: some HTML<HTMLTag.fieldset> {
    _AdjustmentFieldset(
      "Manufacturer's Adjustments",
      adjustments: adjustments,
      fieldNamePrefix: "manufacturersAdjustment"
    )
  }
}

private struct _AdjustmentFieldset: HTML, Sendable {

  let adjustments: CoolingCapacityAdjustment?
  let title: String
  let totalFieldName: String
  let sensibleFieldName: String

  init(
    _ title: String,
    adjustments: CoolingCapacityAdjustment?,
    fieldNamePrefix: String
  ) {
    self.adjustments = adjustments
    self.title = title
    self.totalFieldName = "\(fieldNamePrefix)Total"
    self.sensibleFieldName = "\(fieldNamePrefix)Sensible"
  }

  var body: some HTML<HTMLTag.fieldset> {
    fieldset {
      legend(.class("fieldset-legend")) { title }

      div(.class("flex gap-4")) {
        PercentField(
          "Total",
          percent: adjustments?.total,
          inputAttributes: .name(totalFieldName)
        )

        PercentField(
          "Sensible",
          percent: adjustments?.sensible,
          inputAttributes: .name(sensibleFieldName)
        )
      }
    }
  }
}
