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
  let coolingInterpolationResponse: CoolingInterpolation.Response?
  let heatingInterpolations: [(HeatingInterpolation, HeatingInterpolation.Response)]

  var project: Project { details.project }

  var body: some HTML {
    Navbar(userID: user.id)
    div(.class("flex flex-col m-10 space-y-6")) {

      div(.class("flex flex-wrap md:flex-nowrap")) {
        Section(projectID: project.id, section: .project(details.project))
        div(.class("divider divider-horizontal")) {}
        Section(projectID: project.id, section: .designInfo(details.designInfo))
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

      Section(
        projectID: project.id,
        section: .coolingInterpolation(details: details, response: coolingInterpolationResponse)
      )

      Section(
        projectID: project.id,
        section: .heatingInterpolation(heatingInterpolations)
      )

    }
    .fieldsetStyle(.roundedBox)
    .temperatureViewStyle(.hstack(gap: 2))
    .percentViewStyle(.hstack(gap: 2))
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

          case .coolingInterpolation(let interpolation, let designInfo, let response):
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
              if interpolation != nil {
                div(.class("divider")) {
                  span(.class("text-xl text-accent font-bold")) { "Result" }
                }
                CoolingInterpolationResponseTable(response: response)
              }
            }

          case .heatingInterpolation(let heatingInterpolations):
            // FIX: Heating interpolation results.
            SectionHeader(tooltip: "Edit heating") {
              HeatingInterpolationForm(
                projectID: projectID,
                interpolations: heatingInterpolations?.reduce(into: []) { $0.append($1.0) } ?? []
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
    case coolingInterpolation(
      CoolingInterpolation? = nil, DesignInfo? = nil, CoolingInterpolation.Response? = nil
    )
    case heatingInterpolation([(HeatingInterpolation, HeatingInterpolation.Response)]? = nil)

    static func coolingInterpolation(
      details: Project.Details,
      response: CoolingInterpolation.Response?
    ) -> Self {
      .coolingInterpolation(details.coolingInterpolation, details.designInfo, response)
    }

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
