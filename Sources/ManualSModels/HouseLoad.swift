import Foundation
import SharedModels
import Tagged

public struct HouseLoad: Codable, Equatable, Identifiable, Sendable {

  public let id: Tagged<Self, UUID>
  public let projectID: Project.ID
  public let heating: Double
  public let cooling: CoolingLoad
  public let createdAt: Date
  public let updatedAt: Date

  public init(
    id: Tagged<Self, UUID>,
    projectID: Project.ID,
    heating: Double,
    cooling: CoolingLoad,
    createdAt: Date,
    updatedAt: Date
  ) {
    self.id = id
    self.projectID = projectID
    self.heating = heating
    self.cooling = cooling
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}

extension HouseLoad {
  public struct Create: Codable, Equatable, Sendable {

    public let projectID: Project.ID
    public let heating: Double
    public let coolingTotal: Double
    public let coolingSensible: Double

    public init(
      projectID: Project.ID,
      heating: Double,
      coolingTotal: Double,
      coolingSensible: Double
    ) {
      self.projectID = projectID
      self.heating = heating
      self.coolingTotal = coolingTotal
      self.coolingSensible = coolingSensible
    }
  }

  public struct Update: Codable, Equatable, Sendable {

    public let heating: Double?
    public let coolingTotal: Double?
    public let coolingSensible: Double?

    public init(
      heating: Double? = nil,
      coolingTotal: Double? = nil,
      coolingSensible: Double? = nil
    ) {
      self.heating = heating
      self.coolingTotal = coolingTotal
      self.coolingSensible = coolingSensible
    }
  }

}
