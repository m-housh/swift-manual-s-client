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
    projects: ProjectViewController { _ in
      // FIX: Navigate to project detail view.
      await ResultView {
        @Dependency(\.auth) var auth
        @Dependency(\.sharedDatabase) var database
        let user = try auth.currentUser()
        return try await (
          user.id,
          database.projects.fetch(user.id, .first)
        )
      } onSuccess: { userID, projects in
        ProjectsTable(userID: userID, projects: projects)
      }
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
      return .redirect(to: "/projects")
    // return .redirect {
    //   // HomePage()
    // }
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
              try await Task.sleep(for: .seconds(1.5))
              return DesignInfoView(projectID: projectID, designInfo: .mock)
            }
          }
        case .submit(_):
          fatalError()
        }
      default:
        fatalError()
      }
    case .shared(let route):
      return try await sharedController.view(for: route, on: request)
    }
  }
}
