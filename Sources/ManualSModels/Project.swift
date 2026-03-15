import Dependencies
import Foundation
import Tagged

@_exported import struct SharedModels.Project

extension Project {
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
}
