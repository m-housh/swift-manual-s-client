import Dependencies
import DependenciesMacros
import Fluent
import ManualSModels
import SharedDatabase
import SharedModels

extension DependencyValues {
  public var database: ManualSDatabase {
    get { self[ManualSDatabase.self] }
    set { self[ManualSDatabase.self] = newValue }
  }
}

public struct ManualSDatabase: Sendable {

  public var houseLoads: HouseLoads
  public var migrations: SharedDatabase.Migrations
  var shared: SharedDatabase

  public var users: SharedDatabase.Users {
    get { shared.users }
    set { shared.users = newValue }
  }

  public var userProfiles: SharedDatabase.UserProfiles {
    get { shared.userProfiles }
    set { shared.userProfiles = newValue }
  }

  public var projects: SharedDatabase.Projects {
    get { shared.projects }
    set { shared.projects = newValue }
  }

  @DependencyClient
  public struct HouseLoads: Sendable {
    var create: @Sendable (HouseLoad.Create) async throws -> HouseLoad
    var delete: @Sendable (HouseLoad.ID) async throws -> Void
    var fetch: @Sendable (Project.ID) async throws -> HouseLoad?
    var get: @Sendable (HouseLoad.ID) async throws -> HouseLoad?
    var update: @Sendable (HouseLoad.ID, HouseLoad.Update) async throws -> HouseLoad
  }
}

extension ManualSDatabase.HouseLoads: TestDependencyKey {
  public static let testValue = Self()
}

extension ManualSDatabase: TestDependencyKey {
  public static let testValue = Self(
    houseLoads: .testValue,
    migrations: .testValue,
    shared: .testValue
  )

  public static func live(on database: any Database) -> Self {
    .init(
      houseLoads: .live(database: database),
      migrations: .liveMigrations(),
      shared: .live(on: database)
    )
  }
}
