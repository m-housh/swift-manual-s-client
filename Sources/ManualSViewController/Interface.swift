import AuthClient
import Dependencies
import Elementary
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
    switch route {
    case .index:
      return .view { HomePage() }
    case .designInfo(let route):
      fatalError()
    case .shared(let route):
      return try await sharedController.view(for: route, on: request)
    }
  }
}
