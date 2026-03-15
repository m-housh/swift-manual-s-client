import Dependencies
import Foundation
import Tagged

/// Represents a single duct design project / system.
///
/// Holds items such as project name and address.
public struct Project: Codable, Equatable, Identifiable, Sendable {

  /// The unique ID of the project.
  public let id: Tagged<Self, UUID>

  /// The name of the project.
  public let name: String

  /// The street address of the project.
  public let streetAddress: String

  /// The city of the project.
  public let city: String

  /// The state of the project.
  public let state: String

  /// The zip code of the project.
  public let zipCode: String

  /// When the project was created in the database.
  public let createdAt: Date

  /// When the project was updated in the database.
  public let updatedAt: Date

  public init(
    id: Tagged<Self, UUID>,
    name: String,
    streetAddress: String,
    city: String,
    state: String,
    zipCode: String,
    sensibleHeatRatio: Double? = nil,
    createdAt: Date,
    updatedAt: Date
  ) {
    self.id = id
    self.name = name
    self.streetAddress = streetAddress
    self.city = city
    self.state = state
    self.zipCode = zipCode
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}

extension Project {
  /// Represents the data needed to create a new project.
  public struct Create: Codable, Equatable, Sendable {

    /// The name of the project.
    public let name: String
    /// The street address of the project.
    public let streetAddress: String
    /// The city of the project.
    public let city: String
    /// The state of the project.
    public let state: String
    /// The zip code of the project.
    public let zipCode: String

    public init(
      name: String,
      streetAddress: String,
      city: String,
      state: String,
      zipCode: String,
    ) {
      self.name = name
      self.streetAddress = streetAddress
      self.city = city
      self.state = state
      self.zipCode = zipCode
    }
  }

  public struct Details: Codable, Equatable, Sendable {

    public let project: Project
    public let designInfo: DesignInfo?
    public let systemType: SystemType?
    public let proposedEquipment: ProposedEquipment?
    public let houseLoad: HouseLoad?
    public let coolingInterpolation: CoolingInterpolation?
    public let heatingInterpolation: HeatingInterpolation?

    public init(
      project: Project,
      designInfo: DesignInfo? = nil,
      systemType: SystemType? = nil,
      proposedEquipment: ProposedEquipment? = nil,
      houseLoad: HouseLoad? = nil,
      coolingInterpolation: CoolingInterpolation? = nil,
      heatingInterpolation: HeatingInterpolation? = nil
    ) {
      self.project = project
      self.designInfo = designInfo
      self.systemType = systemType
      self.proposedEquipment = proposedEquipment
      self.houseLoad = houseLoad
      self.coolingInterpolation = coolingInterpolation
      self.heatingInterpolation = heatingInterpolation
    }
  }

  /// Represents fields that can be updated for a project that has already been created.
  ///
  /// Only fields that are supplied get updated in the database.
  public struct Update: Codable, Equatable, Sendable {

    /// The name of the project.
    public let name: String?
    /// The street address of the project.
    public let streetAddress: String?
    /// The city of the project.
    public let city: String?
    /// The state of the project.
    public let state: String?
    /// The zip code of the project.
    public let zipCode: String?

    public init(
      name: String? = nil,
      streetAddress: String? = nil,
      city: String? = nil,
      state: String? = nil,
      zipCode: String? = nil,
    ) {
      self.name = name
      self.streetAddress = streetAddress
      self.city = city
      self.state = state
      self.zipCode = zipCode
    }
  }
}

#if DEBUG
  extension Project {
    public static var mock: Self {
      @Dependency(\.uuid) var uuid
      @Dependency(\.date.now) var now

      return .init(
        id: .init(uuid()),
        name: "Testy McTestface",
        streetAddress: "123 Sesame St.",
        city: "Manhattan",
        state: "NY",
        zipCode: "10001",
        createdAt: now,
        updatedAt: now
      )
    }
  }
#endif
