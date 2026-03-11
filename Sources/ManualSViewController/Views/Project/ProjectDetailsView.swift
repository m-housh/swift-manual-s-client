import Dependencies
import Elementary
import ElementaryHTMX
import Foundation
import ManualSModels
import ManualSRouter
import SharedModels
import SharedStyleguide
import SharedViews

struct ProjectDetailsView: HTML, Sendable {

  let project: Project
  let designInfo: DesignInfo? = .mock
  let systemType: SystemType.Cooling? = .mock
  let proposedEquipment: ProposedEquipment? = .mock
  let houseLoad: HouseLoad? = .mock
  let heatingFormType: HeatingFormType = .none

  var body: some HTML {
    div(.class("flex flex-col m-10 space-y-6")) {
      div(.class("flex flex-wrap md:flex-nowrap")) {
        div(.class("w-full md:w-[50%]")) {
          Section("Project") {
            SectionHeader(tooltip: "Edit project") {
              ProjectForm(project: project)
            }
            ProjectTable(project: project)
          }
        }

        div(.class("w-full md:w-[50%]")) {
          Section("Design Info") {
            LoadableView(route: .projectDetail(project.id, .designInfo(.index))) {
              DesignInfoSection(projectID: project.id, designInfo: nil)
            }
          }
        }
      }

      Section("System Type") {
        SectionHeader(systemType?.label, tooltip: "Edit system type") {
          CoolingSystemTypeForm(systemType: systemType)
        }
      }

      Section("Proposed Equipment") {
        SectionHeader(
          tooltip: "Edit proposed equipment",
          modalAttributes: [.class("max-w-none w-[90%]")]
        ) {
          ProposedEquipmentForm(proposedEquipment: proposedEquipment)
        }
        ProposedEquipmentView(proposedEquipment: proposedEquipment)
      }

      Section("Manual-J") {
        SectionHeader(tooltip: "Edit manual-j") {
          HouseLoadForm(houseLoad: houseLoad)
        }
        HouseLoadView(houseLoad: houseLoad)
      }

      Section("Interpolation") {
        SectionHeader(tooltip: "Edit interpolation", formID: "noInterpolation") {
          OneWayForm(style: .indoor, outdoorDesignTemperature: 92)
        }

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
