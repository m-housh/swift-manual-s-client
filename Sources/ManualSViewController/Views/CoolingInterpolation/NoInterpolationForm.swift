import Elementary
import ElementaryHTMX
import ManualSModels
import SharedStyleguide

struct NoInterpolationForm: HTML, Identifiable, Sendable {

  static let id = "noInterpolationForm"

  var id: String { Self.id }

  var body: some HTML<HTMLTag.form> {
    form {
      FormTitle { "No Interpolation" }
      CoolingCapacityFieldset(capacity: nil)
      ManufacturersAdjustmentFieldset(adjustments: nil)
      AltitudeAdjustmentFieldset(adjustments: nil)
    }
  }
}
