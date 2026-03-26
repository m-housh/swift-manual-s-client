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
    div(.class("flex flex-col p-6 space-y-6 justify-center")) {
      // div(.class("flex flex-wrap md:flex-nowrap w-full max-w-[1200px] mx-auto")) {
      Section(projectID: project.id, section: .project(details.project))
      // div(.class("divider divider-horizontal")) {}
      Section(projectID: project.id, section: .designInfo(details.designInfo))
      // }

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
      Elementary.section(
        .id(id),
        // .class("card w-full max-w-[1200px] mx-auto"),
        .class("card bg-base-100 shadow max-w-5xl mx-auto w-full")
      ) {
        // div(.class("divider")) {
        //   Title { section.title }
        //     .attributes(.class("text-primary tracking-wide"))
        // }
        div(.class("card-body")) {
          // div(.class("flex justify-between items-center")) {
          //   Title { section.title }
          //     .attributes(.class("card-title"))
          //   // Edit button / form.
          // }
          switch section {

          case .project(let project):
            if let project {
              SectionHeader(section.title, tooltip: "Edit project") {
                ProjectForm(project: project)
              }
              ProjectTable(project: project)
            }

          case .designInfo(let designInfo):
            SectionHeader(section.title, tooltip: "Edit design info") {
              DesignInfoForm(projectID: projectID, designInfo: designInfo)
            }
            // DesignInfoTable(projectID: projectID, designInfo: designInfo)
            DesignInfoView(designInfo: designInfo)

          case .coolingSystemType(let systemType):
            SectionHeader(
              section.title,
              // systemType?.cooling?.label,
              tooltip: "Edit system type"
            ) {
              CoolingSystemTypeForm(
                projectID: projectID,
                systemTypeID: systemType?.id,
                systemType: systemType?.cooling
              )
            }
            CoolingSystemTypeView(systemType: systemType?.cooling)

          case .proposedEquipment(let proposedEquipment):
            SectionHeader(
              section.title,
              tooltip: "Edit proposed equipment",
              modalAttributes: [.class("max-w-[1080px] w-[90%]")]
            ) {
              ProposedEquipmentForm(projectID: projectID, proposedEquipment: proposedEquipment)
            }
            ProposedEquipmentView(proposedEquipment: proposedEquipment)

          case .houseLoad(let houseLoad):
            SectionHeader(section.title, tooltip: "Edit manual-j") {
              HouseLoadForm(projectID: projectID, houseLoad: houseLoad)
            }
            HouseLoadView(houseLoad: houseLoad)

          case .coolingInterpolation(let interpolation, let designInfo, let response):
            SectionHeader(
              section.title,
              tooltip: "Edit interpolation",
              modalAttributes: [.class("max-w-[1080px] w-[90%] min-h-[80%]")]
            ) {
              CoolingInterpolationForm(
                projectID: projectID,
                designInfo: designInfo,
                interpolation: interpolation
              )
            }

            InterpolationTable(projectID: projectID, coolingInterpolation: interpolation)

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
            SectionHeader(section.title, tooltip: "Edit heating") {
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
        .titleStyle(.cardTitle)
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
    attributes(.class("bg-base-100 rounded-box p-4"))
  }
}
