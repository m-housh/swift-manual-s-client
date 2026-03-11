import Dependencies
import Foundation
import ManualSModels
import ManualSRouter
import Testing
import URLRouting

@Suite
struct CoolingInterpolationRouteTests {
  let router = CoolingInterpolation.ViewRoute.router

  @Test(
    arguments: SubmitRouteArgument.allCases
  )
  func submitRoute(arg: SubmitRouteArgument) throws {
    let request = URLRequestData(
      method: "POST",
      path: "/cooling",
      body: .init(arg.body.utf8)
    )
    let sut = try router.match(request: .init(data: request)!)
    #expect(sut == .submit(arg.expected))
  }

  @Test(
    arguments: SubmitRouteArgument.allCases
  )
  func updateRoute(arg: SubmitRouteArgument) throws {
    let request = URLRequestData(
      method: "PATCH",
      path: "/cooling/\(UUID(0))",
      body: .init(arg.body.utf8)
    )
    let sut = try router.match(request: .init(data: request)!)
    #expect(sut == .update(.init(UUID(0)), arg.expected))
  }
}

struct SubmitRouteArgument {
  let body: String
  let expected: CoolingInterpolation.FormIntermediate

  init(_ body: String, _ expected: CoolingInterpolation.FormIntermediate) {
    self.body = body
    self.expected = expected
  }

  static let allCases = [Self.noInterpolation, .oneWayIndoor, .oneWayOutdoor, .twoWay]

  static let noInterpolation = Self(
    "projectID=\(UUID(0))&coolingTotal=1111&coolingSensible=1111",
    CoolingInterpolation.FormIntermediate.noInterpolation(
      .init(projectID: .init(UUID(0)), coolingTotal: 1111, coolingSensible: 1111)
    )
  )

  static let oneWayIndoor = Self(
    "projectID=\(UUID(0))&aboveDesignIndoorWetBulb=95&aboveDesignTotalCapacity=1234&aboveDesignSensibleCapacity=1234&belowDesignIndoorWetBulb=85&belowDesignTotalCapacity=1234&belowDesignSensibleCapacity=1234",
    CoolingInterpolation.FormIntermediate.oneWayIndoor(
      .init(
        projectID: .init(UUID(0)), aboveDesignIndoorWetBulb: 95,
        aboveDesignTotalCapacity: 1234, aboveDesignSensibleCapacity: 1234,
        belowDesignIndoorWetBulb: 85, belowDesignTotalCapacity: 1234,
        belowDesignSensibleCapacity: 1234)
    )
  )

  static let oneWayOutdoor = Self(
    "projectID=\(UUID(0))&aboveDesignOutdoorTemperature=95&aboveDesignTotalCapacity=1234&aboveDesignSensibleCapacity=1234&belowDesignOutdoorTemperature=85&belowDesignTotalCapacity=1234&belowDesignSensibleCapacity=1234",
    CoolingInterpolation.FormIntermediate.oneWayOutdoor(
      .init(
        projectID: .init(UUID(0)), aboveDesignOutdoorTemperature: 95,
        aboveDesignTotalCapacity: 1234, aboveDesignSensibleCapacity: 1234,
        belowDesignOutdoorTemperature: 85, belowDesignTotalCapacity: 1234,
        belowDesignSensibleCapacity: 1234)
    )
  )

  static let twoWay = Self(
    "projectID=\(UUID(0))"
      + "&aboveDesignOutdoorTemperature=95"
      + "&aboveDesignAboveIndoorWetBulb=67&aboveDesignAboveTotalCapacity=1234&aboveDesignAboveSensibleCapacity=1234"
      + "&aboveDesignBelowIndoorWetBulb=62&aboveDesignBelowTotalCapacity=1234&aboveDesignBelowSensibleCapacity=1234"
      + "&belowDesignOutdoorTemperature=85"
      + "&belowDesignAboveIndoorWetBulb=67&belowDesignAboveTotalCapacity=1234&belowDesignAboveSensibleCapacity=1234"
      + "&belowDesignBelowIndoorWetBulb=62&belowDesignBelowTotalCapacity=1234&belowDesignBelowSensibleCapacity=1234",
    CoolingInterpolation.FormIntermediate.twoWay(
      .init(
        projectID: .init(UUID(0)),
        aboveDesignOutdoorTemperature: 95,
        aboveDesignAboveIndoorWetBulb: 67,
        aboveDesignAboveTotalCapacity: 1234,
        aboveDesignAboveSensibleCapacity: 1234,
        aboveDesignBelowIndoorWetBulb: 62,
        aboveDesignBelowTotalCapacity: 1234,
        aboveDesignBelowSensibleCapacity: 1234,
        belowDesignOutdoorTemperature: 85,
        belowDesignAboveIndoorWetBulb: 67,
        belowDesignAboveTotalCapacity: 1234,
        belowDesignAboveSensibleCapacity: 1234,
        belowDesignBelowIndoorWetBulb: 62,
        belowDesignBelowTotalCapacity: 1234,
        belowDesignBelowSensibleCapacity: 1234
      )
    )
  )
}
