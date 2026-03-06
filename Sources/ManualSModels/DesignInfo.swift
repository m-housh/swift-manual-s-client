import Dependencies
import Foundation
import SharedModels
import Tagged

public struct DesignInfo: Codable, Equatable, Identifiable, Sendable {

  public let id: Tagged<Self, UUID>
  public let projectID: Project.ID
  public let elevation: Int
  public let summerOutdoorTemperature: Int
  public let summerIndoorTemperature: Int
  public let summerIndoorHumidity: Percent
  public let winterOutdoorTemperature: Int
  public let createdAt: Date
  public let updatedAt: Date

  public init(
    id: Tagged<DesignInfo, UUID>,
    projectID: Project.ID,
    elevation: Int,
    summerOutdoorTemperature: Int,
    summerIndoorTemperature: Int,
    summerIndoorHumidity: Percent,
    winterOutdoorTemperature: Int,
    createdAt: Date,
    updatedAt: Date
  ) {
    self.id = id
    self.projectID = projectID
    self.elevation = elevation
    self.summerOutdoorTemperature = summerOutdoorTemperature
    self.summerIndoorTemperature = summerIndoorTemperature
    self.summerIndoorHumidity = summerIndoorHumidity
    self.winterOutdoorTemperature = winterOutdoorTemperature
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}

extension DesignInfo {

  public struct Create: Codable, Equatable, Sendable {

    public let projectID: Project.ID
    public let elevation: Int
    public let summerOutdoorTemperature: Int
    public let summerIndoorTemperature: Int
    public let summerIndoorHumidity: Percent
    public let winterOutdoorTemperature: Int

    public init(
      projectID: Project.ID,
      elevation: Int,
      summerOutdoorTemperature: Int,
      summerIndoorTemperature: Int,
      summerIndoorHumidity: Percent,
      winterOutdoorTemperature: Int
    ) {
      self.projectID = projectID
      self.elevation = elevation
      self.summerOutdoorTemperature = summerOutdoorTemperature
      self.summerIndoorTemperature = summerIndoorTemperature
      self.summerIndoorHumidity = summerIndoorHumidity
      self.winterOutdoorTemperature = winterOutdoorTemperature
    }
  }

  public struct Update: Codable, Equatable, Sendable {

    public let elevation: Int?
    public let summerOutdoorTemperature: Int?
    public let summerIndoorTemperature: Int?
    public let summerIndoorHumidity: Percent?
    public let winterOutdoorTemperature: Int?

    public init(
      elevation: Int? = nil,
      summerOutdoorTemperature: Int? = nil,
      summerIndoorTemperature: Int? = nil,
      summerIndoorHumidity: Percent? = nil,
      winterOutdoorTemperature: Int? = nil
    ) {
      self.elevation = elevation
      self.summerOutdoorTemperature = summerOutdoorTemperature
      self.summerIndoorTemperature = summerIndoorTemperature
      self.summerIndoorHumidity = summerIndoorHumidity
      self.winterOutdoorTemperature = winterOutdoorTemperature
    }
  }
}

#if DEBUG
  extension DesignInfo {
    public static var mock: Self {
      @Dependency(\.uuid) var uuid
      @Dependency(\.date.now) var now

      return .init(
        id: .init(uuid()),
        projectID: .init(uuid()),
        elevation: 800,
        summerOutdoorTemperature: 90,
        summerIndoorTemperature: 75,
        summerIndoorHumidity: 50,
        winterOutdoorTemperature: 5,
        createdAt: now,
        updatedAt: now
      )

    }
  }
#endif
