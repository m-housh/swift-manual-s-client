import Elementary
import ElementaryHTMX
import ManualSModels
import SharedStyleguide

struct ProposedEquipmentForm: HTML, Identifiable, Sendable {

  static let id = "proposedEquipmentForm"

  var id: String { Self.id }
  let proposedEquipment: ProposedEquipment?

  var body: some HTML<HTMLTag.form> {
    Form {
      FormTitle { "Proposed Equipment" }
      if let proposedEquipment {
        input(.hidden, .value(proposedEquipment.id), .name("id"))
      }

      fieldset(.class("fieldset")) {
        legend(.class("fieldset-legend")) { "Efficiencies" }
        label(.class("input w-full")) {
          span(.class("label")) { "AFUE" }
          input(
            .type(.number),
            .id("afue"),
            .name("afue"),
            .value(proposedEquipment?.afue?.rawValue),
            .min(0),
            .max(100),
            .step(1)
          )
        }

        label(.class("input w-full")) {
          span(.class("label")) { "SEER" }
          input(
            .type(.number),
            .id("seer"),
            .name("seer"),
            .value(proposedEquipment?.seer),
            .min(0),
            .step(0.1)
          )
        }

        label(.class("input w-full")) {
          span(.class("label")) { "HSPF" }
          input(
            .type(.number),
            .id("hspf"),
            .name("hspf"),
            .value(proposedEquipment?.hspf),
            .min(0),
            .step(0.1)
          )
        }

        label(.class("select w-full")) {
          span(.class("label")) { "Fan Speed" }
          Select(
            ProposedEquipment.FanSpeed.allCases,
            value: \.rawValue,
            selected: { proposedEquipment?.fanSpeed == $0 },
            label: \.label
          )
        }
      }

      fieldset(.class("fieldset")) {
        legend(.class("fieldset-legend")) { "Equipment" }
        // FIX: Add new equipment field when clicked
        button(
          .class("btn")
        ) {
          SVG(.circlePlus)
        }
      }

      EquipmentTable(equipment: proposedEquipment?.equipment ?? [])
    }
  }

  struct EquipmentTable: HTML, Sendable {
    let equipment: [ProposedEquipment.Equipment]

    var body: some HTML<HTMLTag.table> {
      table(.class("table table-zebra")) {
        thead {
          tr {
            th { "Manufacturer" }
            th { "Type" }
            th { "Model" }
            th {}
          }
        }
        tbody {
          for item in equipment {
            Row(equipment: item)
          }
        }
      }
    }

    struct Row: HTML, Sendable {
      let equipment: ProposedEquipment.Equipment

      var body: some HTML<HTMLTag.tr> {
        tr(.hx.ext("remove")) {
          td {
            input(
              .class("input"),
              .name("equipment[manufacturer]"),
              .value(equipment.manufacturer),
              .required
            )
          }
          td {
            Select(
              ProposedEquipment.EquipmentType.allCases,
              value: \.rawValue,
              selected: { equipment.equipmentType == $0 },
              label: \.label
            )
            .attributes(
              .class("select"),
              .name("equipment[type]"),
              .required
            )
          }
          td {
            input(
              .class("input"),
              .name("equipment[model]"),
              .value(equipment.model),
              .required
            )
          }
          td {
            button(
              .class("btn btn-error btn-ghost"),
              .data("remove", value: "true")
            ) {
              SVG(.trash)
            }
          }
        }
      }
    }
  }
}
