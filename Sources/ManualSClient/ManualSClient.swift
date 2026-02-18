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

  public typealias AFUE = Tagged<Tag.AFUE, Percent>
  public typealias CapacityAtDesign = Tagged<Tag.CapacityAtDesign, Double>
  public typealias CoolingLoad = Tagged<Tag.CoolingLoad, CoolingCapacity>
  public typealias Elevation = Tagged<Tag.Elevation, Double>
  public typealias HeatLoss = Tagged<Tag.HeatLoss, Double>
  public typealias Input = Tagged<Tag.Input, Int>
  public typealias KW = Tagged<Tag.KW, Double>
  public typealias OutdoorTemperature = Tagged<Tag.OutdoorTemperature, Double>

  public var coolingDerating: @Sendable (Elevation) async throws -> CoolingDerating
  public var coolingSizeLimits:
    @Sendable (CoolingSizeLimitRequest) async throws -> SizingLimit.Cooling

  // TODO: Add manufacturer adjustments
  public var coolingInterpolation:
    @Sendable (CoolingLoad, OutdoorTemperature, Interpolation.Cooling.Request) async throws ->
      Interpolation.Cooling.Response

  // FIX: Need to handle heat pumps
  public var heatingDerating: @Sendable (SystemType.Heating, Elevation) async throws -> Percent
  public var heatingSizeLimits: @Sendable (SystemType.Heating) async throws -> SizingLimit.Heating

  public var electricHeatingInterpolation:
    @Sendable (KW, HeatLoss) async throws ->
      Interpolation.Heating.Response.Electric

  public var gasOrBoilerHeatingInterpolation:
    @Sendable (Input, ManualSClient.AFUE, HeatLoss, Elevation) async throws ->
      Interpolation.Heating.Response.GasOrBoiler

  public var heatPumpHeatingInterpolation:
    @Sendable (HeatPumpCapacity, HeatLoss, Elevation, OutdoorTemperature) async throws ->
      Interpolation.Heating.Response.HeatPump

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
      coolingInterpolation: { houseLoad, outdoorTemperature, request in
        await request.respond(
          houseLoad: houseLoad.rawValue,
          outdoorDesignTemperature: outdoorTemperature.rawValue,
          manufacturersAdjustments: nil
        )
      },
      heatingDerating: { system, elevation in
        await .init(decimal: system.derating(elevation: elevation.rawValue))
      },
      heatingSizeLimits: { system in
        system.sizingLimit
      },
      electricHeatingInterpolation: { inputKW, heatLoss in
        await .init(
          inputKW: inputKW.rawValue,
          heatLoss: heatLoss.rawValue
        )
      },
      gasOrBoilerHeatingInterpolation: { input, afue, heatLoss, elevation in
        try await .init(
          input: Double(input.rawValue),
          afue: afue.rawValue,
          elevation: elevation.rawValue,
          heatLoss: heatLoss.rawValue
        )
      },
      heatPumpHeatingInterpolation: { capacity, heatLoss, elevation, outdoorTemperature in
        try await .init(
          capacity: capacity,
          heatLoss: heatLoss.rawValue,
          elevation: elevation.rawValue,
          outdoorTemperature: outdoorTemperature.rawValue
        )
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
    public enum AFUE {}
    public enum CapacityAtDesign {}
    public enum CoolingLoad {}
    public enum Elevation {}
    public enum HeatLoss {}
    public enum HeatPumpCapacity {}
    public enum Input {}
    public enum OutdoorTemperature {}
    public enum KW {}
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
