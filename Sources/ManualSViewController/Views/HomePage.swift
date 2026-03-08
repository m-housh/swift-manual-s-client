import Dependencies
import Elementary
import Foundation
import ManualSModels
import SharedStyleguide
import SharedViews

struct HomePage: HTML, Sendable {

  let systemType: SystemType.Cooling? = .mock
  let proposedEquipment: ProposedEquipment? = .mock
  let houseLoad: HouseLoad? = .mock
  let heatingFormType: HeatingFormType = .none

  var body: some HTML {
    div(.class("flex flex-col m-10")) {
      div(.class("flex justify-between")) {
        div(.class("w-[50%] border")) {
          ProjectTable(project: .mock)
        }
        div(.class("w-[50%] border")) {
          DesignInfoView(projectID: .init(UUID(0)), designInfo: .mock)
        }
      }

      div(
        .class(
          """
          flex justify-between items-center w-full bg-secondary border px-4 py-2
          """
        )
      ) {
        Title { "System Type" }
        div {
          span { systemType?.label ?? "" }
        }
        div {
          button(
            .class("btn btn-secondary"),
            .showModal(id: "coolingSystemTypeForm")
          ) {
            SVG(.squarePen)
          }
          .tooltip("Edit system type", position: .left)
        }
        Modal(id: "coolingSystemTypeForm", open: false, displayCloseButton: true) {
          CoolingSystemTypeForm(systemType: systemType)
        }

      }

      ProposedEquipmentView(proposedEquipment: proposedEquipment)

      HouseLoadView(houseLoad: houseLoad)

      // Interpolation
      div(.class("border")) {
        div(.class("flex justify-between items-center w-full bg-primary border px-4 py-2")) {
          Title { "Interpolation" }

          button(.class("btn btn-primary"), .showModal(id: "noInterpolation")) {
            "Open"
          }

          Modal(id: "noInterpolation", open: false, displayCloseButton: true) {
            NoInterpolationForm()
          }
        }
        NoInterpolationTable(response: .mock, sizingLimits: .mock)
      }

      div {
        div(.class("flex justify-between items-center w-full bg-primary border px-4 py-2")) {
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
