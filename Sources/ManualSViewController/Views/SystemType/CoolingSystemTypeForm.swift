import Elementary
import ManualSModels
import SharedStyleguide

struct CoolingSystemTypeForm: HTML, Sendable {

  let systemType: SystemType.Cooling?

  var body: some HTML<HTMLTag.form> {
    form {
      h1(.class("text-2xl font-bold")) { "System Type" }

      fieldset(.class("fieldset")) {
        legend(.class("fieldset-legend")) { "Type" }
        Select(
          SystemType.EquipmentType.allCases,
          value: { $0.rawValue },
          selected: {
            guard let systemType else {
              return $0 == .airConditioner
            }
            return systemType.equipment == $0
          },
          label: \.label
        )
        .attributes(
          .class("select w-full"),
          .id("equipment"),
          .name("equipment"),
          .required
        )
      }

      fieldset(.class("fieldset")) {
        legend(.class("fieldset-legend")) { "Compressor" }
        Select(
          SystemType.CompressorType.allCases,
          value: { $0.rawValue },
          selected: {
            guard let systemType else {
              return $0 == .singleSpeed
            }
            return systemType.compressor == $0
          },
          label: \.label
        )
        .attributes(
          .class("select w-full"),
          .name("compressor"),
          .id("compressor"),
          .required
        )
      }

      fieldset(.class("fieldset")) {
        legend(.class("fieldset-legend")) { "Climate" }
        Select(
          SystemType.ClimateType.allCases,
          value: { $0.rawValue },
          selected: {
            guard let systemType else {
              return $0 == .mildWinterOrLatentLoad
            }
            return systemType.climate == $0
          },
          label: \.label
        )
        .attributes(
          .class("select w-full"),
          .id("climate"),
          .name("climate"),
          .required
        )
      }

      SubmitButton()
        .attributes(.class("btn-block"))
    }
  }
}
