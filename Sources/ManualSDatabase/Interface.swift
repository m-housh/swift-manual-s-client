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

  public var designInfo: DesignInfoRepository
  public var houseLoads: HouseLoads
  public var migrations: SharedDatabase.Migrations
  public var shared: SharedDatabase

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
  public struct DesignInfoRepository: Sendable {
    public var create: @Sendable (DesignInfo.Create) async throws -> DesignInfo
    public var delete: @Sendable (DesignInfo.ID) async throws -> Void
    public var fetch: @Sendable (Project.ID) async throws -> DesignInfo?
    public var get: @Sendable (DesignInfo.ID) async throws -> DesignInfo?
    public var update: @Sendable (DesignInfo.ID, DesignInfo.Update) async throws -> DesignInfo
  }

  @DependencyClient
  public struct HouseLoads: Sendable {
    public var create: @Sendable (HouseLoad.Create) async throws -> HouseLoad
    public var delete: @Sendable (HouseLoad.ID) async throws -> Void
    public var fetch: @Sendable (Project.ID) async throws -> HouseLoad?
    public var get: @Sendable (HouseLoad.ID) async throws -> HouseLoad?
    public var update: @Sendable (HouseLoad.ID, HouseLoad.Update) async throws -> HouseLoad
  }
}

extension ManualSDatabase.DesignInfoRepository: TestDependencyKey {
  public static let testValue = Self()
}

extension ManualSDatabase.HouseLoads: TestDependencyKey {
  public static let testValue = Self()
}

extension ManualSDatabase: TestDependencyKey {
  public static let testValue = Self(
    designInfo: .testValue,
    houseLoads: .testValue,
    migrations: .testValue,
    shared: .testValue
  )

  public static func live(on database: any Database) -> Self {
    .init(
      designInfo: .live(database: database),
      houseLoads: .live(database: database),
      migrations: .live(),
      shared: .live(on: database)
    )
  }
}
