import Dependencies
import Elementary
import Foundation
import ManualSModels
import SharedModels
import SharedStyleguide
import SharedViews

struct HomePage: HTML, Sendable {

  let projectID: Project.ID = .init(UUID(0))
  let designInfo: DesignInfo? = .mock
  let systemType: SystemType.Cooling? = .mock
  let proposedEquipment: ProposedEquipment? = .mock
  let houseLoad: HouseLoad? = .mock
  let heatingFormType: HeatingFormType = .none

  var body: some HTML {
    div(.class("flex flex-col m-10 space-y-6")) {
      div(.class("flex flex-wrap md:flex-nowrap")) {
        div(.class("w-full md:w-[50%]")) {
          Section(
            "Project",
            form: ProjectForm(project: .mock),
            content: ProjectTable(project: .mock)
          )
        }

        div(.class("w-full md:w-[50%]")) {
          Section(
            "Design Info",
            form: DesignInfoForm(projectID: projectID, designInfo: designInfo),
            content: DesignInfoView(projectID: projectID, designInfo: designInfo)
          )
        }
      }

      Section(
        "SystemType",
        extraHeaderContent: systemType?.label,
        form: CoolingSystemTypeForm(systemType: systemType)
      )

      Section(
        "Proposed Equipment",
        form: ProposedEquipmentForm(proposedEquipment: proposedEquipment),
        content: ProposedEquipmentView(proposedEquipment: proposedEquipment)
      )

      Section(
        "Manual J",
        form: HouseLoadForm(houseLoad: houseLoad),
        content: HouseLoadView(houseLoad: houseLoad)
      )

      Section(
        "Interpolation",
        formID: "noInterpolation",
        form: OneWayForm(style: .outdoor, outdoorDesignTemperature: 90),
      ) {
        NoInterpolationTable(
          designAirflow: 800,
          capacity: .init(total: 23456, sensible: 17865),
          manufacturersAdjustments: nil
        )
      }

      Section("Interpolation Result") {
        CoolingInterpolationResponseTable(
          response: .mock,
          sizingLimits: .mock,
          flaggedCapacities: .mock
        )
      }

      div(.class("divider")) {}

      div {
        div(.class("flex justify-between items-center w-full text-primary border px-4 py-2")) {
          Title { "Heating" }

          div(.class("flex space-x-4")) {
            label(.class("select select-secondary")) {
              span(.class("label")) { "Type" }
              Select(
                HeatingFormType.allCases,
                value: \.rawValue,
                selected: { heatingFormType == $0 },
                label: \.label
              )
            }

            button(
              .class("btn btn-primary"),
              .showModal(id: "heatingForm")
            ) {
              SVG(.squarePen)
            }
          }

          Modal(id: "heatingForm", open: false, displayCloseButton: true) {
            // FIX: Should be dynamic based on select field.
            HeatPumpForm(
              altitudeAdjustment: nil,
              capacity: nil,
              proposedKW: nil,
              requiredKW: 14.55
            )
            // BoilerOrFurnaceForm(
            //   altitudeAdjustment: 93,
            //   inputBTU: nil,
            //   interpolationType: .furnace
            // )
          }

        }

        div(.id("heatingData")) {}
      }

    }
  }

  // func section<Form: HTML, Content: HTML>(
  //   _ title: String,
  //   extraTitleContent: String? = nil,
  //   formID: String,
  //   form: Form,
  //   content: Content
  // ) -> some HTML<HTMLTag.div> {
  //   div {
  //     div(.class("divider")) {
  //       Title { title }
  //         .attributes(.class("text-secondary"))
  //     }
  //
  //     div(.class("flex text-secondary items-center px-4 py-2")) {
  //
  //       if let extraTitleContent {
  //         span(.class("text-base-content font-bold")) { extraTitleContent }
  //       }
  //
  //       button(.class("btn btn-secondary btn-ghost"), .showModal(id: formID)) {
  //         SVG(.squarePen)
  //       }
  //       .tooltip("Edit \(title)", position: .left)
  //
  //       Modal(id: formID, open: false, displayCloseButton: true) {
  //         form
  //       }
  //     }
  //     .attributes(.class("justify-between"), when: extraTitleContent != nil)
  //     .attributes(.class("justify-end"), when: extraTitleContent == nil)
  //
  //     content
  //   }
  // }
  //
  // func section<Form: HTML, Content: HTML>(
  //   _ title: String,
  //   extraTitleContent: String? = nil,
  //   formID: String,
  //   form: Form,
  //   @HTMLBuilder content: () -> Content
  // ) -> some HTML<HTMLTag.div> {
  //   section(
  //     title,
  //     extraTitleContent: extraTitleContent,
  //     formID: formID,
  //     form: form,
  //     content: content()
  //   )
  // }
  //
  // func section<Form: HTML, Content: HTML>(
  //   _ title: String,
  //   extraTitleContent: String? = nil,
  //   form: Form,
  //   content: Content
  // ) -> some HTML<HTMLTag.div> where Form: Identifiable, Form.ID == String {
  //   section(
  //     title,
  //     extraTitleContent: extraTitleContent,
  //     formID: form.id,
  //     form: form,
  //     content: content
  //   )
  // }
  //
  // func section<Form: HTML, Content: HTML>(
  //   _ title: String,
  //   extraTitleContent: String? = nil,
  //   form: Form,
  //   @HTMLBuilder content: () -> Content
  // ) -> some HTML<HTMLTag.div> where Form: Identifiable, Form.ID == String {
  //   section(
  //     title,
  //     extraTitleContent: extraTitleContent,
  //     formID: form.id,
  //     form: form,
  //     content: content()
  //   )
  // }

  // TODO: Move to routes.
  enum HeatingFormType: String, CaseIterable {
    case none
    case boiler
    case furnace
    case heatPump

    var label: String {
      switch self {
      case .boiler, .furnace, .none: return rawValue.capitalized
      case .heatPump: return "Heat Pump"
      }
    }
  }
}
