import Dependencies
import Foundation
import ManualSClient
import ManualSModels
import Testing

@Suite
struct ManualSClientTests {

  let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 2
    return formatter
  }()

  let houseLoad = HouseLoad(heating: 49667, cooling: .init(total: 17872, sensible: 13894))

  @Test
  func balancePoint() async throws {
    try await withDependencies {
      $0.manualS = .liveValue
    } operation: {
      @Dependency(\.manualS) var manualS
      let sut = try await manualS.thermalBalancePoint(
        .init(
          capacity: .init(capacityAt47: 24600, capacityAt17: 15100),
          heatLoss: 49667,
          outdoorDesignTemperature: 5
        )
      )
      #expect(numberFormatter.string(for: sut) == "38.52")
    }
  }

  @Test(
    arguments: [
      (49667, nil, "14.55"),
      (49667, 11300, "11.24"),
    ]
  )
  func requiredKW(
    heatLoss: ManualSClient.HeatLoss,
    capacityAtDesign: ManualSClient.CapacityAtDesign?,
    exepcted: String
  ) async throws {
    try await withDependencies {
      $0.manualS = .liveValue
    } operation: {
      @Dependency(\.manualS) var manualS
      let sut = try await manualS.requiredKW(heatLoss, capacityAtDesign)
      #expect(numberFormatter.string(for: sut) == exepcted)
    }
  }

  @Test(
    arguments: [
      (ManualSClient.CoolingSizeLimitRequest.mildWinterOrLatentLoad(compressor: .singleSpeed), 115),
      (ManualSClient.CoolingSizeLimitRequest.mildWinterOrLatentLoad(compressor: .multiSpeed), 120),
      (
        ManualSClient.CoolingSizeLimitRequest.mildWinterOrLatentLoad(compressor: .variableSpeed),
        130
      ),
      (
        ManualSClient.CoolingSizeLimitRequest.coldWinterOrNoLatentLoad(totalCoolingLoad: 17872),
        184
      ),
    ]
  )
  func coolingSizeLimits(request: ManualSClient.CoolingSizeLimitRequest, expected: Int) async throws
  {
    try await withDependencies {
      $0.manualS = .liveValue
    } operation: {
      @Dependency(\.manualS) var manualS
      let sut = try await manualS.coolingSizeLimits(request)
      #expect(sut.oversizing.total == expected)
      #expect(sut.oversizing.latent == 150)
      #expect(sut.undersizing.total == 90)
      #expect(sut.undersizing.sensible == 90)
      #expect(sut.undersizing.latent == 90)
    }
  }

  @Test(
    arguments: [
      (0, 1, 1),
      (1001, 0.99, 0.97),
      (2001, 0.98, 0.94),
      (3001, 0.98, 0.91),
      (4001, 0.97, 0.88),
      (5001, 0.96, 0.85),
      (6001, 0.95, 0.82),
      (7001, 0.94, 0.8),
      (8001, 0.94, 0.77),
      (9001, 0.93, 0.74),
      (10001, 0.92, 0.71),
      (11001, 0.91, 0.68),
      (12001, 0.9, 0.65),
    ]
  )
  func coolingDeratings(elevation: Double, expectedTotal: Double, expectedSensible: Double)
    async throws
  {
    try await withDependencies {
      $0.manualS = .liveValue
    } operation: {
      @Dependency(\.manualS) var manualS
      let sut = try await manualS.coolingDerating(.init(rawValue: elevation))
      #expect(sut.total == .init(decimal: expectedTotal))
      #expect(sut.sensible == .init(decimal: expectedSensible))
    }
  }

  @Test(
    arguments: [
      (SystemType.Heating.boiler, 0, 1),
      (SystemType.Heating.boiler, 1001, 0.96),
      (SystemType.Heating.boiler, 2001, 0.92),
      (SystemType.Heating.boiler, 3001, 0.88),
      (SystemType.Heating.boiler, 4001, 0.84),
      (SystemType.Heating.boiler, 5001, 0.8),
      (SystemType.Heating.boiler, 6001, 0.76),
      (SystemType.Heating.boiler, 7001, 0.72),
      (SystemType.Heating.boiler, 8001, 0.68),
      (SystemType.Heating.boiler, 9001, 0.64),
      (SystemType.Heating.boiler, 10001, 0.6),
      (SystemType.Heating.boiler, 11001, 0.56),
      (SystemType.Heating.boiler, 12001, 0.52),

      (SystemType.Heating.furnace, 0, 1),
      (SystemType.Heating.furnace, 1001, 0.96),
      (SystemType.Heating.furnace, 2001, 0.92),
      (SystemType.Heating.furnace, 3001, 0.88),
      (SystemType.Heating.furnace, 4001, 0.84),
      (SystemType.Heating.furnace, 5001, 0.8),
      (SystemType.Heating.furnace, 6001, 0.76),
      (SystemType.Heating.furnace, 7001, 0.72),
      (SystemType.Heating.furnace, 8001, 0.68),
      (SystemType.Heating.furnace, 9001, 0.64),
      (SystemType.Heating.furnace, 10001, 0.6),
      (SystemType.Heating.furnace, 11001, 0.56),
      (SystemType.Heating.furnace, 12001, 0.52),

      (SystemType.Heating.heatPump, 0, 1),
      (SystemType.Heating.heatPump, 1001, 0.98),
      (SystemType.Heating.heatPump, 2001, 0.97),
      (SystemType.Heating.heatPump, 3001, 0.95),
      (SystemType.Heating.heatPump, 4001, 0.94),
      (SystemType.Heating.heatPump, 5001, 0.92),
      (SystemType.Heating.heatPump, 6001, 0.9),
      (SystemType.Heating.heatPump, 7001, 0.89),
      (SystemType.Heating.heatPump, 8001, 0.87),
      (SystemType.Heating.heatPump, 9001, 0.86),
      (SystemType.Heating.heatPump, 10001, 0.84),
      (SystemType.Heating.heatPump, 11001, 0.82),
      (SystemType.Heating.heatPump, 12001, 0.81),
    ]
  )
  func heatingDeratings(systemType: SystemType.Heating, elevation: Double, expected: Double)
    async throws
  {

    try await withDependencies {
      $0.manualS = .liveValue
    } operation: {
      @Dependency(\.manualS) var manualS
      let sut = try await manualS.heatingDerating(systemType, .init(rawValue: elevation))
      #expect(sut == .init(decimal: expected))
    }
  }

  @Test(
    arguments: [
      (15, "14.55")
    ]
  )
  func electricHeatInterpolation(inputKW: Double, expected: String) async throws {
    try await withDependencies {
      $0.manualS = .liveValue
    } operation: {
      @Dependency(\.manualS) var manualS
      let sut = try await manualS.electricHeatingInterpolation(
        15,
        .init(rawValue: houseLoad.heating)
      )
      #expect(numberFormatter.string(for: sut.requiredKW) == expected)
      #expect(numberFormatter.string(for: sut.percentOfLoad.rawValue) == "103.08")
    }
  }

  // FIX: test a different elevation.
  @Test
  func heatPumpHeatingInterpolation() async throws {
    try await withDependencies {
      $0.manualS = .liveValue
    } operation: {
      @Dependency(\.manualS) var manualS
      let sut = try await manualS.heatPumpHeatingInterpolation(
        .init(capacityAt47: 24600, capacityAt17: 15100),
        49667,
        0,
        5
      )
      #expect(numberFormatter.string(for: sut.requiredKW) == "11.24")
      #expect(Int(sut.capacityAtDesign) == 11300)
      #expect(numberFormatter.string(for: sut.balancePointTemperature) == "38.52")
      #expect(sut.finalCapacity == .init(capacityAt47: 24600, capacityAt17: 15100))
    }
  }

  @Test
  func furnaceOrBoilerInterpolation() async throws {
    try await withDependencies {
      $0.manualS = .liveValue
    } operation: {
      @Dependency(\.manualS) var manualS
      let sut = try await manualS.gasOrBoilerHeatingInterpolation(
        60000,  // furnace input
        96,  // afue
        49667,  // heat loss
        0  // elevation
      )
      #expect(sut.finalCapacity == 57600)
      #expect(sut.outputCapacity == 57600)
      #expect(numberFormatter.string(for: sut.percentOfLoad.rawValue) == "115.97")
    }
  }

  @Test
  func coolingInterpolation_NoInterpolation() async throws {
    try await withDependencies {
      $0.manualS = .liveValue
    } operation: {
      @Dependency(\.manualS) var manualS
      let sut = try await manualS.coolingInterpolation(
        .init(rawValue: houseLoad.cooling),
        90,
        .noInterpolation(
          .init(
            capacity: .init(
              cfm: 800,
              indoorTemperature: 75,
              indoorWetBulbTemperature: 63,
              outdoorTemperature: 90,
              capacity: .init(total: 22600, sensible: 16850)
            )
          )
        )
      )
      #expect(sut.interpolatedCapacity.total == 22600)
      #expect(sut.interpolatedCapacity.sensible == 16850)
      #expect(sut.excessLatent == 886)
      #expect(sut.finalCapacityAtyDesign.sensible == 17736)
      #expect(numberFormatter.string(for: sut.capacityAsPercentOfLoad.total.rawValue) == "126.45")
      #expect(
        numberFormatter.string(for: sut.capacityAsPercentOfLoad.sensible.rawValue) == "127.65")
      #expect(numberFormatter.string(for: sut.capacityAsPercentOfLoad.latent.rawValue) == "122.27")
    }
  }
}
