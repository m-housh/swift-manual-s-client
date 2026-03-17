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

// FIX: Heating Load should be double.
@DependencyClient
public struct ManualSClient: Sendable {

  public typealias CapacityAtDesign = Tagged<Tag.CapacityAtDesign, Double>
  public typealias Elevation = Tagged<Tag.Elevation, Double>
  public typealias HeatLoss = Tagged<Tag.HeatLoss, Double>

  public var coolingDerating: @Sendable (Elevation) async throws -> CoolingDerating
  public var coolingSizeLimits:
    @Sendable (CoolingSizeLimitRequest) async throws -> SizingLimit.Cooling

  public var coolingInterpolation:
    @Sendable (CoolingInterpolation.Request) async throws -> CoolingInterpolation.Response

  public var heatingDerating: @Sendable (SystemType.Heating, Elevation) async throws -> Percent
  public var heatingSizeLimits: @Sendable (SystemType.Heating) async throws -> SizingLimit.Heating

  public var electricHeatingInterpolation:
    @Sendable (HeatingInterpolation.Request.Electric) async throws ->
      HeatingInterpolation.Response.Electric

  public var gasOrBoilerHeatingInterpolation:
    @Sendable (HeatingInterpolation.Request.FurnaceOrBoiler) async throws ->
      HeatingInterpolation.Response.GasOrBoiler

  public var heatPumpHeatingInterpolation:
    @Sendable (HeatingInterpolation.Request.HeatPump) async throws ->
      HeatingInterpolation.Response.HeatPump

  public var requiredKW: @Sendable (HeatLoss, CapacityAtDesign?) async throws -> Double
  public var thermalBalancePoint: @Sendable (ThermalBalancePointRequest) async throws -> Double
}

extension ManualSClient: DependencyKey {

  public static var liveValue: Self {
    .init(
      coolingDerating: { elevation in
        await .init(elevation: elevation.rawValue)
      },
      coolingSizeLimits: { request in
        try await request.respond()
      },
      coolingInterpolation: { request in
        try await request.respond()
      },
      heatingDerating: { system, elevation in
        await .init(decimal: system.derating(elevation: elevation.rawValue))
      },
      heatingSizeLimits: { system in
        system.sizingLimit
      },
      electricHeatingInterpolation: { request in
        await request.respond()
      },
      gasOrBoilerHeatingInterpolation: { request in
        await request.respond()
      },
      heatPumpHeatingInterpolation: { request in
        try await request.respond()
      },
      requiredKW: { heatLoss, capacityAtDesign in
        await calculateRequiredKW(
          heatLoss: heatLoss.rawValue,
          capacityAtDesign: capacityAtDesign?.rawValue ?? 0
        )
      },
      thermalBalancePoint: { request in
        try await request.respond()
      }
    )
  }

}

extension ManualSClient {

  /// A namespace for tagged types.
  public enum Tag {
    public enum CapacityAtDesign {}
    public enum Elevation {}
    public enum HeatLoss {}
  }

  public enum CoolingSizeLimitRequest: Codable, Equatable, Sendable {
    case mildWinterOrLatentLoad(compressor: SystemType.CompressorType)
    case coldWinterOrNoLatentLoad(totalCoolingLoad: Double)
  }

  public struct ThermalBalancePointRequest: Codable, Equatable, Sendable {

    public let heatLoss: Double
    public let capacity: HeatPumpCapacity
    public let outdoorDesignTemperature: Double

    public init(
      capacity: HeatPumpCapacity,
      heatLoss: Double,
      outdoorDesignTemperature: Double
    ) {
      self.capacity = capacity
      self.heatLoss = heatLoss
      self.outdoorDesignTemperature = outdoorDesignTemperature
    }
  }
}

extension ManualSClient: TestDependencyKey {
  public static let testValue = Self()
}
