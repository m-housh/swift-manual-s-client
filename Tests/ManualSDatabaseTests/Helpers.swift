import AuthClient
import Dependencies
import Fluent
import FluentSQLiteDriver
import ManualSDatabase
import SharedDatabase
import SharedMiddleware
import SharedModels
import Vapor

/// Set's up the database and a test user for running tests that require a
/// a user.
func withTestUser(
  setupDependencies: @escaping @Sendable (inout DependencyValues) -> Void = { _ in },
  operation: @escaping @Sendable (User) async throws -> Void
) async throws {
  try await withTestAppAndDatabase(setupDependencies: setupDependencies) { app, db in
    @Dependency(\.sharedDatabase.users) var users

    let user = try await users.create(
      .init(email: "testy@example.com", password: "super-secret", confirmPassword: "super-secret")
    )
    try await operation(user)
  }
}

func withTestProject(
  setupDependencies: @escaping @Sendable (inout DependencyValues) -> Void = { _ in },
  operation: @escaping @Sendable (Project) async throws -> Void
) async throws {
  try await withTestUser(setupDependencies: setupDependencies) { user in
    @Dependency(\.sharedDatabase.projects) var projects
    let project = try await projects.create(
      user.id,
      .init(
        name: "Testy McTestface",
        streetAddress: "123 Sesame St",
        city: "Manhattan",
        state: "NY",
        zipCode: "10001"
      )
    )
    try await operation(project)
  }
}

public func withTestAppAndDatabase(
  setupDependencies: @escaping @Sendable (inout DependencyValues) -> Void = { _ in },
  test runTest: @Sendable (Application, ManualSDatabase) async throws -> Void,
) async throws {

  let app = try await Application.make(.testing)

  do {
    let sharedDatabase = try await setupDatabase(on: app)
    app.middleware.use(
      DependenciesMiddleware.test(
        database: sharedDatabase,
        setupDependencies: setupDependencies
      )
    )
    try await app.autoMigrate()
    try await withDependencies {
      setupDependencies(&$0)
      $0.database = sharedDatabase
      $0.sharedDatabase = sharedDatabase.shared
    } operation: {
      try await runTest(app, sharedDatabase)
    }
    try await app.autoRevert()
  } catch {
    try? await app.autoRevert()
    try await app.asyncShutdown()
    throw error
  }

  try await app.asyncShutdown()
}

public func withTestDatabase(
  setupDependencies: @escaping @Sendable (inout DependencyValues) -> Void = { _ in },
  test runTest: @Sendable () async throws -> Void,
) async throws {
  try await withTestAppAndDatabase(setupDependencies: setupDependencies) { _, _ in
    try await runTest()
  }
}

private func setupDatabase(on app: Application) async throws -> ManualSDatabase {
  app.databases.use(.sqlite(.memory), as: .sqlite)
  let database = ManualSDatabase.live(on: app.db)
  try await app.migrations.add(database.migrations())
  return database
}

extension DependenciesMiddleware {

  public static func test(
    auth authClient: AuthClient? = nil,
    database: ManualSDatabase,
    logger: Logger = .init(label: "test"),
    setupDependencies: @escaping @Sendable (inout DependencyValues) -> Void = { _ in }
  ) -> Self {
    .init { dependencies, request in
      dependencies.auth = authClient ?? .live(on: request)
      dependencies.database = database
      dependencies.sharedDatabase = database.shared
      dependencies.logger = logger
      setupDependencies(&dependencies)
    }

  }
}
