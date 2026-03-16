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
  let details: Project.Details
  let heatingFormType: HeatingFormType = .none

  var project: Project { details.project }

  var body: some HTML {
    Navbar(userID: user.id)
    div(.class("flex flex-col m-10 space-y-6")) {

      div(.class("flex flex-wrap md:flex-nowrap")) {
        Section(projectID: project.id, section: .project(details.project))
        // .attributes(.class("w-full md:w-[50%]"))
        div(.class("divider divider-horizontal")) {}
        Section(projectID: project.id, section: .designInfo(details.designInfo))
        // .attributes(.class("w-full md:w-[50%]"))
      }

      Section(
        projectID: project.id,
        section: .coolingSystemType(details.systemType)
      )

      Section(
        projectID: project.id,
        section: .proposedEquipment(details.proposedEquipment)
      )

      Section(
        projectID: project.id,
        section: .houseLoad(details.houseLoad)
      )

      // TODO: htmx OOB swap ??

      // FIX: This section should be triggered to update if
      // other forms on the page change.
      Section(
        projectID: project.id,
        section: .coolingInterpolation(details.coolingInterpolation)
      )

      // FIX: This section should be triggered to update if
      // other forms on the page change.
      Section(
        projectID: project.id,
        section: .heatingInterpolation()
      )

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

  struct Section: HTML, Sendable {

    let projectID: Project.ID
    let section: SectionRoute

    private var shouldApplyWidthAttribute: Bool {
      switch section {
      case .project, .designInfo: return true
      default: return false
      }
    }

    var body: some HTML<HTMLTag.section> {
      Elementary.section(.id(id)) {
        div(.class("divider")) {
          Title { section.title }
            .attributes(.class("text-secondary"))
        }
        div {
          switch section {

          case .project(let project):
            if let project {
              SectionHeader(tooltip: "Edit project") {
                ProjectForm(project: project)
              }
              ProjectTable(project: project)
            }

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
            // FIX: Heating interpolation results.
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
      .attributes(.class("w-full md:w-[50%]"), when: shouldApplyWidthAttribute)
    }
  }
}

extension ProjectDetailsView.Section {

  enum SectionRoute: Sendable {
    case project(Project? = nil)
    case designInfo(DesignInfo? = nil)
    case coolingSystemType(SystemType? = nil)
    case proposedEquipment(ProposedEquipment? = nil)
    case houseLoad(HouseLoad? = nil)
    case coolingInterpolation(CoolingInterpolation? = nil, DesignInfo? = nil)
    case heatingInterpolation([(HeatingInterpolation, HeatingInterpolation.Response)]? = nil)

    var id: String {
      switch self {
      case .project: return "projectSection"
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
      case .project: return "Project"
      case .designInfo: return "Design Info"
      case .coolingSystemType: return "System Type"
      case .proposedEquipment: return "Proposed Equipment"
      case .houseLoad: return "Manual-J"
      case .coolingInterpolation: return "Interpolation"
      case .heatingInterpolation: return "Heating"
      }
    }
  }

  // TODO: Remove not using loadable.
  var route: ManualSRoute {
    switch section {
    case .project:
      return .projectDetail(projectID, .index)
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
