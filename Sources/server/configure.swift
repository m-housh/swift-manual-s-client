import Elementary
import Fluent
import FluentSQLiteDriver
import ManualSDatabase
import ManualSViewController
import SharedDatabase
import SharedMiddleware
import SharedModels
import SharedViews
@preconcurrency import URLRouting
import Vapor

// configures your application
func configure(
  _ app: Application
) async throws {
  let db = try await setupDatabase(on: app)
  addMiddleware(to: app, database: db)
  addRoutes(to: app)
  try await app.autoMigrate()
}

private func setupDatabase(on app: Application) async throws -> ManualSDatabase {
  let dbFile = Environment.get("SQLITE_FILE") ?? "db.sqlite"
  app.databases.use(.sqlite(.file(dbFile)), as: .sqlite)
  let db = ManualSDatabase.live(on: app.db)
  try await app.migrations.add(db.migrations())
  return db
}

private func addMiddleware(to app: Application, database: ManualSDatabase) {
  // cors middleware should come before default error middleware using `at: .beginning`
  let corsConfiguration = CORSMiddleware.Configuration(
    allowedOrigin: .all,
    allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
    allowedHeaders: [
      .accept, .authorization, .contentType, .origin,
      .xRequestedWith, .userAgent, .accessControlAllowOrigin,
    ]
  )
  let cors = CORSMiddleware(configuration: corsConfiguration)
  app.middleware.use(cors, at: .beginning)
  // File middleware.
  app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
  // Sessions.
  app.sessions.use(.fluent)
  app.migrations.add(SessionRecord.migration)
  app.middleware.use(app.sessions.middleware)
  // Dependencies
  app.middleware.use(
    DependenciesMiddleware { dependencies, request in
      dependencies.sharedDatabase = database.shared
      dependencies.database = database
      dependencies.auth = .live(on: request)
      dependencies.logger = request.logger
      dependencies.viewResponder = .live(
        title: "Manual-S",
        head: {
          DefaultHead {
            script(.src("/js/main.js")) {}
          }
        }
      )
    }
  )
}

private func addRoutes(to app: Application) {
  app.mount(
    controller: ManualSViewController(),
    routeMiddleware: { route in
      switch route {
      case .shared(let route):
        return route.viewMiddleware()
      default:
        return User.viewAuthMiddleware()
      }
    }
  )
}
