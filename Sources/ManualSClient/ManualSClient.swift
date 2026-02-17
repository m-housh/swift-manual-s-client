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
  public typealias HeatLoss = Tagged<Tag.HeatLoss, Double>
  public typealias CapacityAtDesign = Tagged<Tag.CapacityAtDesign, Double>

  public var thermalBalancePoint: @Sendable (ThermalBalancePointRequest) async throws -> Double
  public var requiredKW: @Sendable (HeatLoss, CapacityAtDesign?) async throws -> Double

}

extension ManualSClient {

  /// A namespace for tagged types.
  public enum Tag {
    public enum HeatLoss {}
    public enum CapacityAtDesign {}
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
