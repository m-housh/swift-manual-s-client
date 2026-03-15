import Dependencies
import Elementary
import ElementaryHTMX
import Foundation
import ManualSModels
import ManualSRouter
import SharedStyleguide
import SharedViews

import struct SharedModels.User

struct ProjectDetailsView: HTML, Sendable {

  let user: User
  let project: Project
  let heatingFormType: HeatingFormType = .none

  var body: some HTML {
    Navbar(userID: user.id)
    div(.class("flex flex-col m-10 space-y-6")) {
      div(.class("flex flex-wrap md:flex-nowrap")) {

        div(.class("w-full md:w-[50%]")) {
          div(.class("divider")) {
            Title { "Project" }
              .attributes(.class("text-secondary"))
          }
          div {
            // FIX:
            // SectionHeader(tooltip: "Edit project") {
            //   // ProjectForm(project: project)
            // }
            ProjectTable(project: project)
          }
          .sectionContentStyle()
        }

        div(.class("divider divider-horizontal")) {}

        div(.class("w-full md:w-[50%]")) {
          LoadableSection(.init(projectID: project.id, section: .designInfo()))
        }
      }

      LoadableSection(.init(projectID: project.id, section: .coolingSystemType()))

      LoadableSection(.init(projectID: project.id, section: .proposedEquipment()))

      LoadableSection(.init(projectID: project.id, section: .houseLoad()))

      LoadableSection(.init(projectID: project.id, section: .coolingInterpolation()))

      LoadableSection(.init(projectID: project.id, section: .heatingInterpolation()))

    }
    .fieldsetStyle(.roundedBox)
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

  struct LoadableSection: HTML, Sendable {
    let section: ProjectDetailsView.Section

    init(_ section: ProjectDetailsView.Section) {
      self.section = section
    }

    var body: some HTML {
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
  struct Section: HTML, Sendable {

    let projectID: Project.ID
    let section: SectionRoute

    var body: some HTML {
      div(.id(id)) {
        div {
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

          case .coolingInterpolation(let interpolation, let designInfo):
            SectionHeader(
              tooltip: "Edit interpolation",
              modalAttributes: [.class("max-w-none w-[90%] min-h-[80%]")]
            ) {
              CoolingInterpolationForm(
                projectID: projectID,
                designInfo: designInfo,
                interpolation: interpolation
              )
            }

            InterpolationTable(projectID: projectID, coolingInterpolation: interpolation)

            // FIX: The results need to be reinterpreted if house load changes.
            div(.id("coolingInterpolationResult")) {
              if let interpolation {
                div(.class("divider")) {
                  span(.class("text-xl text-accent font-bold")) { "Result" }
                }
                LoadableView(
                  route: .projectDetail(
                    projectID,
                    .interpolations(.cooling(.result(interpolation.id)))
                  )
                ) {}
              }
            }

          case .heatingInterpolation(let heatingInterpolations):
            SectionHeader(tooltip: "Edit heating") {
              HeatingInterpolationForm(
                projectID: projectID,
                interpolation: heatingInterpolations?.first?.0
              )
            }
            if let heatingInterpolations {
              HeatingInterpolationsView(
                projectID: projectID,
                interpolations: heatingInterpolations
              )
            }
          }
        }
        .fieldsetStyle(.roundedBox)
        .sectionContentStyle()
      }
    }

  }
}

extension ProjectDetailsView.Section {

  enum SectionRoute: Sendable {

    case designInfo(DesignInfo? = nil)
    case coolingSystemType(SystemType? = nil)
    case proposedEquipment(ProposedEquipment? = nil)
    case houseLoad(HouseLoad? = nil)
    case coolingInterpolation(CoolingInterpolation? = nil, DesignInfo? = nil)
    case heatingInterpolation([(HeatingInterpolation, HeatingInterpolation.Response)]? = nil)

    var id: String {
      switch self {
      case .designInfo: return "designInfoSection"
      case .coolingSystemType: return "coolingSystemTypeSection"
      case .proposedEquipment: return "proposedEquipmentSection"
      case .houseLoad: return "houseLoadSection"
      case .coolingInterpolation: return "coolingInterpolationSection"
      case .heatingInterpolation: return "heatingInterpolationSection"
      }
    }

    var title: String {
      switch self {
      case .designInfo: return "Design Info"
      case .coolingSystemType: return "System Type"
      case .proposedEquipment: return "Proposed Equipment"
      case .houseLoad: return "Manual-J"
      case .coolingInterpolation: return "Interpolation"
      case .heatingInterpolation: return "Heating"
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
    case .coolingInterpolation:
      return .projectDetail(projectID, .interpolations(.cooling(.index)))
    case .heatingInterpolation:
      return .projectDetail(projectID, .interpolations(.heating(.index)))
    }
  }

  static func id(_ key: SectionRoute) -> String {
    key.id
  }
  var title: String { section.title }
  var id: String { section.id }
}

extension HTML<HTMLTag.table> {
  func projectDetailStyle() -> some HTML<HTMLTag.table> {
    attributes(.class("table-border"))
  }
}

extension HTML<HTMLTag.div> {
  func sectionContentStyle() -> some HTML<HTMLTag.div> {
    attributes(.class("bg-base-200 border-base-300 border rounded-box shadow-lg p-6"))
  }
}
