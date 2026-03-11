import AuthClient
import Dependencies
import Elementary
import ManualSDatabase
import ManualSRouter
import SharedDatabase
import SharedMiddleware
import SharedModels
import SharedStyleguide
import SharedViews
import Vapor

public struct ManualSViewController: ViewController {

  public init() {}

  let sharedController = SharedViewController(
    auth: AuthViewController(),
    projects: ProjectViewController { project in
      ProjectDetailsView(project: project)
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
      switch route {
      case .index:
        return .view {
          await ResultView {
            guard let project = try await database.projects.get(projectID) else {
              throw NotFoundError()
            }
            return ProjectDetailsView(project: project)
          }
        }
      case .designInfo(let route):
        switch route {
        case .index:
          return .view {
            await ResultView {
              let designInfo = try await database.designInfo.fetch(projectID)
              return DesignInfoSection(projectID: projectID, designInfo: designInfo)
            }
          }
        case .submit(let form):
          return .view {
            await ResultView {
              let designInfo = try await database.designInfo.create(form)
              return DesignInfoSection(projectID: projectID, designInfo: designInfo)
            }
          }
        case .update(let designInfoID, let updates):
          return .view {
            await ResultView {
              let designInfo = try await database.designInfo.update(designInfoID, updates)
              return DesignInfoSection(projectID: projectID, designInfo: designInfo)
            }
          }
        }
      default:
        fatalError()
      }
    case .shared(let route):
      return try await sharedController.view(for: route, on: request)
    }
  }
}
