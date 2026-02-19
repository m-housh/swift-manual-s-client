import Dependencies
import Foundation
import ManualSClient
import ManualSModels
import Testing

@Suite
struct ManualSClientTests {

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
      #expect(sut.string() == "38.52")
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
      #expect(sut.string() == exepcted)
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
        .init(kilowatts: 15, heatingLoad: Int(houseLoad.heating))
      )
      #expect(sut.requiredKW.string() == expected)
      #expect(sut.percentOfLoad.rawValue.string() == "103.08")
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
        .init(
          capacity: .init(capacityAt47: 24600, capacityAt17: 15100),
          heatingLoad: 49667,
          projectElevation: 0,
          outdoorDesignTemperature: 5
        )
      )
      #expect(sut.requiredKW.string() == "11.24")
      #expect(Int(sut.capacityAtDesign) == 11300)
      #expect(sut.balancePointTemperature.string() == "38.52")
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
        .init(
          inputBTU: 60000,
          afue: 96,
          heatingLoad: 49667,
          projectElevation: 0
        )
      )
      #expect(sut.finalCapacity == 57600)
      #expect(sut.outputCapacity == 57600)
      #expect(sut.percentOfLoad.string() == "115.97")
    }
  }

  @Test
  func coolingInterpolation_NoInterpolation() async throws {
    try await withDependencies {
      $0.manualS = .liveValue
    } operation: {
      @Dependency(\.manualS) var manualS
      let sut = try await manualS.coolingInterpolation(
        .init(
          coolingLoad: houseLoad.cooling,
          manufacturersAdjustments: nil,
          outdoorDesignTemperature: 90,
          projectElevation: 0,
          interpolation: .noInterpolation(total: 22600, sensible: 16850)
        )
      )
      #expect(sut.interpolatedCapacity.total == 22600)
      #expect(sut.interpolatedCapacity.sensible == 16850)
      #expect(sut.excessLatent == 886)
      #expect(sut.finalCapacityAtDesign.sensible == 17736)
      #expect(sut.capacityAsPercentOfLoad.total.string() == "126.45")
      #expect(
        sut.capacityAsPercentOfLoad.sensible.string() == "127.65")
      #expect(sut.capacityAsPercentOfLoad.latent.string() == "122.27")
    }
  }

  @Test
  func coolingInterpolation_OneWayIndoor() async throws {
    try await withDependencies {
      $0.manualS = .liveValue
    } operation: {
      @Dependency(\.manualS) var manualS
      let sut = try await manualS.coolingInterpolation(
        .init(
          coolingLoad: houseLoad.cooling,
          manufacturersAdjustments: nil,
          outdoorDesignTemperature: 90,
          projectElevation: 0,
          interpolation: .oneWayIndoor(
            .init(
              aboveDesign: .init(
                indoorWetBulbTemperature: 67, capacity: .init(total: 24828, sensible: 15937)),
              belowDesign: .init(
                indoorWetBulbTemperature: 62, capacity: .init(total: 23046, sensible: 19078))
            )
          )
        )
      )
      #expect(sut.interpolatedCapacity.total.string() == "23,402.4")
      #expect(sut.interpolatedCapacity.sensible.string() == "18,449.8")
      #expect(sut.excessLatent == 487)
      #expect(sut.finalCapacityAtDesign.sensible == 18937.1)
      #expect(sut.capacityAsPercentOfLoad.total.string() == "130.94")
      #expect(
        sut.capacityAsPercentOfLoad.sensible.string() == "136.3")
      #expect(sut.capacityAsPercentOfLoad.latent.string() == "112.25")
    }
  }

  @Test
  func coolingInterpolation_OneWayOutdoor() async throws {
    try await withDependencies {
      $0.manualS = .liveValue
    } operation: {
      @Dependency(\.manualS) var manualS
      let sut = try await manualS.coolingInterpolation(
        .init(
          coolingLoad: houseLoad.cooling,
          manufacturersAdjustments: nil,
          outdoorDesignTemperature: 90,
          projectElevation: 0,
          interpolation: .oneWayOutdoor(
            .init(
              aboveDesign: .init(
                outdoorTemperature: 95, capacity: .init(total: 22000, sensible: 16600)
              ),
              belowDesign: .init(
                outdoorTemperature: 85, capacity: .init(total: 23200, sensible: 17100)
              )
            )
          )
        )
      )
      #expect(sut.interpolatedCapacity == .init(total: 22600, sensible: 16850))
      #expect(sut.excessLatent == 886)
      #expect(sut.finalCapacityAtDesign == .init(total: 22600, sensible: 17736))
      #expect(sut.capacityAsPercentOfLoad.total.string() == "126.45")
      #expect(sut.capacityAsPercentOfLoad.sensible.string() == "127.65")
      #expect(sut.capacityAsPercentOfLoad.latent.string() == "122.27")
    }
  }

  @Test
  func coolingInterpolation_TwoWay() async throws {

    try await withDependencies {
      $0.manualS = .liveValue
    } operation: {
      @Dependency(\.manualS) var manualS
      let sut = try await manualS.coolingInterpolation(
        .init(
          coolingLoad: houseLoad.cooling,
          manufacturersAdjustments: nil,
          outdoorDesignTemperature: 90,
          projectElevation: 0,
          interpolation: .twoWay(
            .init(
              aboveDesign: .init(
                outdoorTemperature: 95,
                aboveWetBulb: .init(
                  indoorWetBulbTemperature: 67,
                  capacity: .init(total: 24828, sensible: 15937)
                ),
                belowWetBulb: .init(
                  indoorWetBulbTemperature: 62,
                  capacity: .init(total: 23046, sensible: 19078)
                )
              ),
              belowDesign: .init(
                outdoorTemperature: 85,
                aboveWetBulb: .init(
                  indoorWetBulbTemperature: 67,
                  capacity: .init(total: 25986, sensible: 16330)
                ),
                belowWetBulb: .init(
                  indoorWetBulbTemperature: 62,
                  capacity: .init(total: 24029, sensible: 19605)
                )
              )
            )
          )
        )
      )
      #expect(sut.interpolatedCapacity.total.string(digits: 0) == "23,911")
      #expect(sut.interpolatedCapacity.sensible.string(digits: 0) == "18,700")
      #expect(sut.excessLatent == 616)
      #expect(sut.finalCapacityAtDesign.total.string(digits: 0) == "23,911")
      #expect(sut.finalCapacityAtDesign.sensible.string(digits: 0) == "19,317")
      #expect(sut.capacityAsPercentOfLoad.total.string(digits: 0) == "134")
      #expect(sut.capacityAsPercentOfLoad.sensible.string(digits: 0) == "139")
      #expect(sut.capacityAsPercentOfLoad.latent.string(digits: 0) == "116")
    }
  }
}
