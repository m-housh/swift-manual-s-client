import Dependencies
import Foundation
import ManualSModels
import ManualSRouter
import Testing
import URLRouting

@Suite
struct HeatingInterpolationRouteTests {
  let router = HeatingInterpolation.ViewRoute.router

  @Test(
    arguments: [
      (
        "projectID=\(UUID(0))&afue=98&inputBTU=60000",
        HeatingInterpolation.Interpolation.boilerOrFurnace(.init(afue: 98, inputBTU: 60000))
      ),
      (
        "projectID=\(UUID(0))&kilowatts=15",
        HeatingInterpolation.Interpolation.electric(kilowatts: 15)
      ),
      (
        "projectID=\(UUID(0))&capacityAt47=15&capacityAt17=14",
        HeatingInterpolation.Interpolation.heatPump(
          capacity: .init(capacityAt47: 15, capacityAt17: 14)
        )
      ),
    ]
  )
  func submit(body: String, expected: HeatingInterpolation.Interpolation) throws {
    let request = URLRequestData(method: "POST", path: "/heating", body: .init(body.utf8))
    let sut = try router.match(request: .init(data: request)!)
    #expect(sut == .submit(.init(projectID: .init(UUID(0)), interpolations: [expected])))
  }

  @Test(
    arguments: [
      (
        "afue=98&inputBTU=60000",
        HeatingInterpolation.Interpolation.boilerOrFurnace(.init(afue: 98, inputBTU: 60000))
      ),
      (
        "kilowatts=15",
        HeatingInterpolation.Interpolation.electric(kilowatts: 15)
      ),
      (
        "capacityAt47=15&capacityAt17=14",
        HeatingInterpolation.Interpolation.heatPump(
          capacity: .init(capacityAt47: 15, capacityAt17: 14)
        )
      ),
    ]
  )
  func update(body: String, expected: HeatingInterpolation.Interpolation) throws {
    let request = URLRequestData(
      method: "POST", path: "/heating/\(UUID(1))", body: .init(body.utf8))
    let sut = try router.match(request: .init(data: request)!)
    #expect(
      sut == .update(.init(UUID(1)), .init(interpolations: [expected])))
  }
}
