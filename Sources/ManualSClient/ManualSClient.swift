import Dependencies
import DependenciesMacros
import ManualSModels
import Tagged

extension DependencyValues {
  public var manualS: ManualSClient {
    get { self[ManualSClient.self] }
    set { self[ManualSClient.self] = newValue }
  }
}

@DependencyClient
public struct ManualSClient: Sendable {

  public typealias CapacityAtDesign = Tagged<Tag.CapacityAtDesign, Double>
  public typealias Elevation = Tagged<Tag.Elevation, Double>
  public typealias HeatLoss = Tagged<Tag.HeatLoss, Double>

  public var coolingDerating: @Sendable (SystemType.Cooling) async throws -> CoolingDerating
  public var heatingDerating: @Sendable (SystemType.Heating, Elevation) async throws -> Double
  public var requiredKW: @Sendable (HeatLoss, CapacityAtDesign?) async throws -> Double
  public var coolingSizeLimits: @Sendable (SystemType.Cooling) async throws -> SizingLimit.Cooling
  public var heatingSizeLimits: @Sendable (SystemType.Heating) async throws -> SizingLimit.Heating
  public var thermalBalancePoint: @Sendable (ThermalBalancePointRequest) async throws -> Double

}

extension ManualSClient {

  /// A namespace for tagged types.
  public enum Tag {
    public enum CapacityAtDesign {}
    public enum Elevation {}
    public enum HeatLoss {}
  }

  public struct ThermalBalancePointRequest: Codable, Equatable, Sendable {

    public let heatLoss: Double
    public let capacityAt47: Double
    public let capacityAt17: Double
    public let outdoorDesignTemperature: Int

    public init(
      heatLoss: Double,
      capacityAt47: Double,
      capacityAt17: Double,
      outdoorDesignTemperature: Int
    ) {
      self.heatLoss = heatLoss
      self.capacityAt47 = capacityAt47
      self.capacityAt17 = capacityAt17
      self.outdoorDesignTemperature = outdoorDesignTemperature
    }
  }
}

extension ManualSClient: TestDependencyKey {
  public static let testValue = Self()
}
