import AuthClient
import Dependencies
import Elementary
import ManualSClient
import ManualSDatabase
import ManualSModels
import ManualSRouter
import SharedDatabase
import SharedMiddleware
import SharedModels
import SharedStyleguide
import SharedViews
import Vapor

// FIX: Need to redirect to projects / home page after signup flow is complete
public struct ManualSViewController: ViewController {

  public init() {}

  let sharedController = SharedViewController(
    auth: AuthViewController(),
    projects: ProjectViewController { project in
      // FIX: What do we do with project view controller, until it's removed from
      //      shared setup.
      // @Dependency(\.auth) var auth
      // return try ProjectDetailsView(user: auth.currentUser(), project: project)
    },
    users: UserViewController()
  )

  public func view(
    for route: ManualSRoute,
    on request: Request
  ) async throws -> ViewResponse {

    @Dependency(\.database) var database

    switch route {
    case .index:
      return .redirect(to: ManualSRoute.router.path(for: .shared(.project(.index))))

    case .projectDetail(let projectID, let route):
      return try await route.view(projectID: projectID)

    case .shared(let route):
      return try await sharedController.view(for: route, on: request)
    }
  }
}

extension ManualSRoute.ProjectDetail {

  func view(projectID: ManualSModels.Project.ID) async throws -> ViewResponse {
    @Dependency(\.auth) var auth
    @Dependency(\.database) var database
    @Dependency(\.manualS) var manualS

    switch self {
    case .index:
      return .view {
        await ResultView {
          let details = try await fetchDetails(for: projectID)
          let user = try auth.currentUser()
          return ProjectDetailsView(
            user: user,
            details: details.projectDetails,
            coolingInterpolationResponse: details.coolingInterpolationResponse,
            heatingInterpolations: details.heatingInterpolations ?? []
          )
        }
      }
    case .designInfo(let route):
      switch route {
      case .index:
        return .view {
          await ResultView {
            let designInfo = try await database.designInfo.fetch(projectID)
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .designInfo(designInfo)
            )
          }
        }
      case .submit(let form):
        return .projectDetailsUpdate(projectID) {
          await ResultView {
            let designInfo = try await database.designInfo.create(form)
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .designInfo(designInfo)
            )
          }
        }
      case .update(let designInfoID, let updates):
        return .projectDetailsUpdate(projectID) {
          await ResultView {
            let designInfo = try await database.designInfo.update(designInfoID, updates)
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .designInfo(designInfo)
            )
          }
        }
      }

    case .systemTypes(let route):
      switch route {
      case .index:
        return .view {
          await ResultView {
            let systemTypes = try await database.systemTypes.fetch(projectID)
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .coolingSystemType(systemTypes)
            )
          }
        }
      case .submit(let form):
        return .projectDetailsUpdate(projectID) {
          await ResultView {
            let systemTypes = try await database.systemTypes.create(form)
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .coolingSystemType(systemTypes)
            )
          }
        }
      case .update(let id, let updates):
        return .projectDetailsUpdate(projectID) {
          await ResultView {
            let systemTypes = try await database.systemTypes.update(id, updates)
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .coolingSystemType(systemTypes)
            )
          }
        }
      }

    case .proposedEquipment(let route):
      switch route {
      case .index:
        return .view {
          await ResultView {
            let proposedEquipment = try await database.proposedEquipment.fetch(projectID)
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .proposedEquipment(proposedEquipment)
            )
          }
        }
      case .equipmentRow:
        return .view {
          ProposedEquipmentForm.EquipmentTable.Row(equipment: nil)
        }
      case .submit(let form):
        return .projectDetailsUpdate(projectID) {
          await ResultView {
            let proposedEquipment = try await database.proposedEquipment.create(form.toCreate())
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .proposedEquipment(proposedEquipment)
            )
          }
        }
      case .update(let id, let updates):
        return .projectDetailsUpdate(projectID) {
          await ResultView {
            let proposedEquipment = try await database.proposedEquipment.update(
              id, updates.toUpdate())
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .proposedEquipment(proposedEquipment)
            )
          }
        }
      }

    case .houseLoads(let route):
      switch route {
      case .index:
        return .view {
          await ResultView {
            let houseLoads = try await database.houseLoads.fetch(projectID)
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .houseLoad(houseLoads)
            )
          }
        }
      case .submit(let form):
        return .projectDetailsUpdate(projectID) {
          await ResultView {
            let houseLoads = try await database.houseLoads.create(form)
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .houseLoad(houseLoads)
            )
          }
        }
      case .update(let id, let updates):
        return .projectDetailsUpdate(projectID) {
          await ResultView {
            let houseLoads = try await database.houseLoads.update(id, updates)
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .houseLoad(houseLoads)
            )
          }
        }
      }

    case .interpolations(.cooling(let route)):
      switch route {
      case .index:
        return .projectDetailsUpdate(projectID)
      case .submit(let form):
        return .projectDetailsUpdate(projectID) {
          _ = try await database.coolingInterpolations.create(form.toCreate())
        }
      case .update(let id, let updates):
        return .projectDetailsUpdate(projectID) {
          _ = try await database.coolingInterpolations.update(id, updates.toUpdate())
        }
      }

    case .interpolations(.heating(let route)):
      switch route {
      case .index:
        return .projectDetailsUpdate(projectID)
      case .submit(let form):
        return .projectDetailsUpdate(projectID) {
          _ = try await database.heatingInterpolations.create(form)
        }
      case .update(_, _):
        // FIX:
        fatalError()
      }
    }
  }

}

@dynamicMemberLookup
private struct ProjectDetailsAndInterpolations: Sendable {

  let projectDetails: Project.Details
  let coolingInterpolationResponse: CoolingInterpolation.Response?
  let heatingInterpolations: [(HeatingInterpolation, HeatingInterpolation.Response)]?

  internal init(
    details: Project.Details,
    coolingInterpolationResponse: CoolingInterpolation.Response? = nil,
    heatingInterpolations: [(HeatingInterpolation, HeatingInterpolation.Response)]? = nil
  ) {
    self.projectDetails = details
    self.coolingInterpolationResponse = coolingInterpolationResponse
    self.heatingInterpolations = heatingInterpolations
  }

  subscript<T>(dynamicMember keyPath: KeyPath<Project.Details, T>) -> T {
    projectDetails[keyPath: keyPath]
  }
}

private func fetchDetails(
  for projectID: Project.ID
) async throws -> ProjectDetailsAndInterpolations {
  @Dependency(\.database) var database
  @Dependency(\.manualS) var manualS

  guard let details = try await database.projects.fetchDetails(projectID)
  else { throw NotFoundError() }

  return .init(
    details: details,
    coolingInterpolationResponse: await manualS.coolingInterpolation(projectDetails: details),
    heatingInterpolations: try await manualS.heatingInterpolations(projectDetails: details)
  )
}

extension ViewResponse {

  fileprivate static func projectDetailsUpdate(
    _ projectID: Project.ID,
    catching callback: @escaping @Sendable () async throws -> Void = {}
  ) -> Self {
    self.view {
      await ResultView {
        @Dependency(\.database) var database
        @Dependency(\.manualS) var manualS

        _ = try await callback()
        return try await fetchDetails(for: projectID)
      } onSuccess: { projectDetails in
        Group {
          ProjectDetailsView.Section(
            projectID: projectID,
            section: .coolingInterpolation(projectDetails)
          )
          .attributes(.hx.swapOOB(true))

          ProjectDetailsView.Section(
            projectID: projectID,
            section: .heatingInterpolation(projectDetails.heatingInterpolations)
          )
          .attributes(.hx.swapOOB(true))
        }
      }
    }
  }

  fileprivate static func projectDetailsUpdate<V: HTML>(
    _ projectID: Project.ID,
    @HTMLBuilder content: @escaping @Sendable () async -> V
  ) -> Self where V: Sendable {
    self.view {
      await ResultView {
        @Dependency(\.database) var database
        @Dependency(\.manualS) var manualS
        let details = try await fetchDetails(for: projectID)
        return (
          details,
          await content()
        )
      } onSuccess: { (projectDetails: ProjectDetailsAndInterpolations, content: V) in
        Group {
          content
          ProjectDetailsView.Section(
            projectID: projectID,
            section: .coolingInterpolation(projectDetails)
          )
          .attributes(.hx.swapOOB(true))

          ProjectDetailsView.Section(
            projectID: projectID,
            section: .heatingInterpolation(projectDetails.heatingInterpolations)
          )
          .attributes(.hx.swapOOB(true))
        }
      }
    }
  }
}

extension ProjectDetailsView.Section.SectionRoute {
  fileprivate static func coolingInterpolation(_ projectDetails: ProjectDetailsAndInterpolations)
    -> Self
  {
    .coolingInterpolation(
      projectDetails.coolingInterpolation,
      projectDetails.designInfo,
      projectDetails.coolingInterpolationResponse
    )
  }
}
