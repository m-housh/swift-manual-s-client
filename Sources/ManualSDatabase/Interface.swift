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

  public var coolingInterpolations: CoolingInterpolationRepository
  public var designInfo: DesignInfoRepository
  public var heatingInterpolations: HeatingInterpolationRepository
  public var houseLoads: HouseLoads
  public var migrations: SharedDatabase.Migrations
  public var proposedEquipment: ProposedEquipmentRepository
  public var shared: SharedDatabase
  public var systemTypes: SystemTypeRepository

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
  public struct CoolingInterpolationRepository: Sendable {
    public var create: @Sendable (CoolingInterpolation.Create) async throws -> CoolingInterpolation
    public var delete: @Sendable (CoolingInterpolation.ID) async throws -> Void
    public var fetch: @Sendable (Project.ID) async throws -> CoolingInterpolation?
    public var get: @Sendable (CoolingInterpolation.ID) async throws -> CoolingInterpolation?
    public var update:
      @Sendable (CoolingInterpolation.ID, CoolingInterpolation.Update) async throws ->
        CoolingInterpolation
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
  public struct HeatingInterpolationRepository: Sendable {
    public var create: @Sendable (HeatingInterpolation.Create) async throws -> HeatingInterpolation
    public var delete: @Sendable (HeatingInterpolation.ID) async throws -> Void
    public var fetch: @Sendable (Project.ID) async throws -> HeatingInterpolation?
    public var get: @Sendable (HeatingInterpolation.ID) async throws -> HeatingInterpolation?
    public var update:
      @Sendable (HeatingInterpolation.ID, HeatingInterpolation.Update) async throws ->
        HeatingInterpolation
  }

  @DependencyClient
  public struct HouseLoads: Sendable {
    public var create: @Sendable (HouseLoad.Create) async throws -> HouseLoad
    public var delete: @Sendable (HouseLoad.ID) async throws -> Void
    public var fetch: @Sendable (Project.ID) async throws -> HouseLoad?
    public var get: @Sendable (HouseLoad.ID) async throws -> HouseLoad?
    public var update: @Sendable (HouseLoad.ID, HouseLoad.Update) async throws -> HouseLoad
  }

  @DependencyClient
  public struct ProposedEquipmentRepository: Sendable {
    public var create: @Sendable (ProposedEquipment.Create) async throws -> ProposedEquipment
    public var delete: @Sendable (ProposedEquipment.ID) async throws -> Void
    public var fetch: @Sendable (Project.ID) async throws -> ProposedEquipment?
    public var get: @Sendable (ProposedEquipment.ID) async throws -> ProposedEquipment?
    public var update:
      @Sendable (ProposedEquipment.ID, ProposedEquipment.Update) async throws -> ProposedEquipment
  }

  @DependencyClient
  public struct SystemTypeRepository: Sendable {
    public var create: @Sendable (SystemType.Create) async throws -> SystemType
    public var delete: @Sendable (SystemType.ID) async throws -> Void
    public var fetch: @Sendable (Project.ID) async throws -> SystemType?
    public var get: @Sendable (SystemType.ID) async throws -> SystemType?
    public var update: @Sendable (SystemType.ID, SystemType.Update) async throws -> SystemType
  }
}

extension ManualSDatabase.CoolingInterpolationRepository: TestDependencyKey {
  public static let testValue = Self()
}

extension ManualSDatabase.DesignInfoRepository: TestDependencyKey {
  public static let testValue = Self()
}

extension ManualSDatabase.HeatingInterpolationRepository: TestDependencyKey {
  public static let testValue = Self()
}

extension ManualSDatabase.HouseLoads: TestDependencyKey {
  public static let testValue = Self()
}

extension ManualSDatabase.ProposedEquipmentRepository: TestDependencyKey {
  public static let testValue = Self()
}

extension ManualSDatabase.SystemTypeRepository: TestDependencyKey {
  public static let testValue = Self()
}

extension ManualSDatabase: TestDependencyKey {
  public static let testValue = Self(
    coolingInterpolations: .testValue,
    designInfo: .testValue,
    heatingInterpolations: .testValue,
    houseLoads: .testValue,
    migrations: .testValue,
    proposedEquipment: .testValue,
    shared: .testValue,
    systemTypes: .testValue
  )

  public static func live(on database: any Database) -> Self {
    .init(
      coolingInterpolations: .live(database: database),
      designInfo: .live(database: database),
      heatingInterpolations: .live(database: database),
      houseLoads: .live(database: database),
      migrations: .live(),
      proposedEquipment: .live(database: database),
      shared: .live(on: database),
      systemTypes: .live(database: database)
    )
  }
}
