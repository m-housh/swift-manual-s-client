import Dependencies
import Elementary
import ManualSModels
import SharedModels
import SharedStyleguide

struct DesignInfoSection: HTML, Sendable {
  static let id = "designInfoSection"

  let projectID: Project.ID
  let designInfo: DesignInfo?

  var body: some HTML {
    div(.id(Self.id)) {
      SectionHeader(tooltip: "Edit design info") {
        DesignInfoForm(projectID: projectID, designInfo: designInfo)
      }
      DesignInfoTable(projectID: projectID, designInfo: designInfo)
    }
  }
}
