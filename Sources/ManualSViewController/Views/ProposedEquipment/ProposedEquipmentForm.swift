import Elementary
import ElementaryHTMX
import ManualSModels
import ManualSRouter
import SharedModels
import SharedStyleguide

struct ProposedEquipmentForm: HTML, Identifiable, Sendable {

  static let id = "proposedEquipmentForm"

  var id: String { Self.id }
  let projectID: Project.ID
  let proposedEquipment: ProposedEquipment?

  var route: String {
    ManualSRoute.router.path(for: .projectDetail(projectID, .proposedEquipment(.index)))
      .appendingPath(proposedEquipment?.id)
  }

  var body: some HTML<HTMLTag.form> {
    Form(
      proposedEquipment == nil
        ? .hx.post(route)
        : .hx.patch(route),
      .hx.target(id: ProjectDetailsView.Section.id(.proposedEquipment())),
      .hx.swap(.outerHTML)
    ) {
      FormTitle { "Proposed Equipment" }
      if let proposedEquipment {
        input(.hidden, .value(proposedEquipment.id), .name("id"))
      }

      input(.hidden, .name("projectID"), .value(projectID))

      Fieldset("Equipment") {
        p(.class("text-accent font-bold italic")) {
          """
          Equipment used for the project.
          """
        }
        EquipmentTable(projectID: projectID, equipment: proposedEquipment?.equipment ?? [])
      }

      Fieldset("Efficiencies") {
        div(.class("grid grid-cols-1 md:grid-cols-2 gap-x-4 gap-y-2")) {

          label(.class("select w-full")) {
            span(.class("label")) { "Fan Speed" }
            Select(
              ProposedEquipment.FanSpeed.allCases,
              value: \.rawValue,
              selected: {
                proposedEquipment == nil
                  ? $0 == .mediumHigh
                  : $0 == proposedEquipment?.fanSpeed
              },
              label: \.label
            )
            .attributes(.name("fanSpeed"))
          }

          label(.class("input w-full")) {
            span(.class("label")) { "AFUE" }
            input(
              .type(.number),
              .id("afue"),
              .name("afue"),
              .value(proposedEquipment?.afue?.rawValue),
              .placeholder("97"),
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
              .placeholder("16"),
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
              .placeholder("9.5"),
              .min(0),
              .step(0.1)
            )
          }

        }
      }

      SubmitButton()
        .attributes(.type(.submit), .class("btn-block"))
    }
  }

  struct EquipmentTable: HTML, Sendable {
    let projectID: Project.ID
    let equipment: [ProposedEquipment.Equipment]

    var body: some HTML<HTMLTag.table> {
      table(.class("table table-zebra")) {
        thead {
          tr {
            th { "Manufacturer" }
            th { "Type" }
            th { "Model" }
            th {
              div(.class("flex justify-end")) {
                button(
                  .class("btn btn-primary btn-ghost"),
                  .hx.get(
                    route: ManualSRoute.projectDetail(projectID, .proposedEquipment(.equipmentRow))),
                  .hx.target(id: "equipmentTable"),
                  .hx.swap(.beforeEnd)
                ) {
                  SVG(.circlePlus)
                }
              }
            }
          }
        }
        tbody(.id("equipmentTable")) {
          for item in equipment {
            Row(equipment: item)
          }
        }
      }
    }

    struct Row: HTML, Sendable {
      let equipment: ProposedEquipment.Equipment?

      var body: some HTML<HTMLTag.tr> {
        tr(.hx.ext("remove")) {
          td {
            input(
              .class("input"),
              .name("equipment[manufacturer]"),
              .value(equipment?.manufacturer),
              .required
            )
          }
          td {
            Select(
              ProposedEquipment.EquipmentType.allCases,
              value: \.rawValue,
              selected: { equipment?.equipmentType == $0 },
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
              .value(equipment?.model),
              .required
            )
          }
          td {
            div(.class("flex justify-end")) {
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
}
