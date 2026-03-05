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

  public init(
    id: Tagged<DesignInfo, UUID>,
    projectID: Project.ID,
    elevation: Int,
    summerOutdoorTemperature: Int,
    summerIndoorTemperature: Int,
    summerIndoorHumidity: Percent,
    winterOutdoorTemperature: Int
  ) {
    self.id = id
    self.projectID = projectID
    self.elevation = elevation
    self.summerOutdoorTemperature = summerOutdoorTemperature
    self.summerIndoorTemperature = summerIndoorTemperature
    self.summerIndoorHumidity = summerIndoorHumidity
    self.winterOutdoorTemperature = winterOutdoorTemperature
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
