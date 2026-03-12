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
          NotLoadedSection(.designInfo(project.id, nil))
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

  struct NotLoadedSection: HTML, Sendable {
    let section: ProjectDetailsView._Section

    init(_ section: ProjectDetailsView._Section) {
      self.section = section
    }

    var body: some HTML {
      // Section(section.title) {
      Elementary.section {
        div(.class("divider")) {
          Title { section.title }
            .attributes(.class("text-secondary"))
        }
        LoadableView(route: section.route) {
          section
        }
      }
    }
  }

  // FIX: Rename when all sections have migrated.
  enum _Section: HTML, Sendable {

    case designInfo(Project.ID, DesignInfo?)

    var body: some HTML {
      div(.id(ID(self).id)) {
        switch self {
        case .designInfo(let projectID, let designInfo):
          SectionHeader(tooltip: "Edit design info") {
            DesignInfoForm(projectID: projectID, designInfo: designInfo)
          }
          DesignInfoTable(projectID: projectID, designInfo: designInfo)
        }
      }
    }

    var route: ManualSRoute {
      switch self {
      case .designInfo(let projectID, _):
        return .projectDetail(projectID, .designInfo(.index))
      }
    }

  }
}

extension ProjectDetailsView._Section {

  static func id(_ key: ID) -> String {
    key.id
  }

  var id: ID { ID(self) }

  var title: String { id.title }

  enum ID: String, Sendable {
    case designInfo

    var id: String {
      "\(rawValue)Section"
    }

    var title: String {
      switch self {
      case .designInfo: return "Design Info"
      }
    }

    init(_ section: ProjectDetailsView._Section) {
      switch section {
      case .designInfo:
        self = .designInfo
      }
    }
  }

}
