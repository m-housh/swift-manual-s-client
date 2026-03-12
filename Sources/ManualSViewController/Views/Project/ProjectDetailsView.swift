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
          NotLoadedSection(.init(projectID: project.id, section: .designInfo()))
        }
      }

      NotLoadedSection(.init(projectID: project.id, section: .coolingSystemType()))

      NotLoadedSection(.init(projectID: project.id, section: .proposedEquipment()))

      NotLoadedSection(.init(projectID: project.id, section: .houseLoad()))

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
  struct _Section: HTML, Sendable {

    let projectID: Project.ID
    let section: SectionRoute

    var body: some HTML {
      div(.id(id)) {
        switch section {

        case .designInfo(let designInfo):
          SectionHeader(tooltip: "Edit design info") {
            DesignInfoForm(projectID: projectID, designInfo: designInfo)
          }
          DesignInfoTable(projectID: projectID, designInfo: designInfo)

        case .coolingSystemType(let systemType):
          SectionHeader(systemType?.cooling?.label, tooltip: "Edit system type") {
            CoolingSystemTypeForm(
              projectID: projectID,
              systemTypeID: systemType?.id,
              systemType: systemType?.cooling
            )
          }

        case .proposedEquipment(let proposedEquipment):
          SectionHeader(
            tooltip: "Edit proposed equipment",
            modalAttributes: [.class("max-w-none w-[90%]")]
          ) {
            ProposedEquipmentForm(projectID: projectID, proposedEquipment: proposedEquipment)
          }
          ProposedEquipmentView(proposedEquipment: proposedEquipment)

        case .houseLoad(let houseLoad):
          SectionHeader(tooltip: "Edit manual-j") {
            HouseLoadForm(projectID: projectID, houseLoad: houseLoad)
          }
          HouseLoadView(houseLoad: houseLoad)

        }
      }
    }

  }
}

extension ProjectDetailsView._Section {

  enum SectionRoute: Equatable, Sendable {

    case designInfo(DesignInfo? = nil)
    case coolingSystemType(SystemType? = nil)
    case proposedEquipment(ProposedEquipment? = nil)
    case houseLoad(HouseLoad? = nil)

    var id: String {
      switch self {
      case .designInfo: return "designInfoSection"
      case .coolingSystemType: return "coolingSystemTypeSection"
      case .proposedEquipment: return "proposedEquipmentSection"
      case .houseLoad: return "houseLoadSection"
      }
    }

    var title: String {
      switch self {
      case .designInfo: return "Design Info"
      case .coolingSystemType: return "System Type"
      case .proposedEquipment: return "Proposed Equipment"
      case .houseLoad: return "Manual-J"
      }
    }
  }

  var route: ManualSRoute {
    switch section {
    case .designInfo:
      return .projectDetail(projectID, .designInfo(.index))
    case .coolingSystemType:
      return .projectDetail(projectID, .systemTypes(.index))
    case .proposedEquipment:
      return .projectDetail(projectID, .proposedEquipment(.index))
    case .houseLoad:
      return .projectDetail(projectID, .houseLoads(.index))
    }
  }

  static func id(_ key: SectionRoute) -> String {
    key.id
  }
  var title: String { section.title }
  var id: String { section.id }
}
