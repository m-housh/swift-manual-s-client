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
        "projectID=\(UUID(0))&afue=98&inputBTU=60000&type=boiler",
        HeatingInterpolation.Interpolation.boilerOrFurnace(
          .init(afue: 98, inputBTU: 60000, type: .boiler))
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
    #expect(sut == .submit(.init(projectID: .init(UUID(0)), interpolation: expected)))
  }

  // @Test(
  //   arguments: [
  //     (
  //       "projectID=\(UUID(0))&afue=98&inputBTU=60000&type=furnace&boilerOrFurnaceID=\(UUID(1))",
  //       HeatingInterpolation.Interpolation.boilerOrFurnace(
  //         .init(afue: 98, inputBTU: 60000, type: .furnace))
  //     ),
  //     (
  //       "projectID=\(UUID(0))&kilowatts=15&electricID=\(UUID(1))",
  //       HeatingInterpolation.Interpolation.electric(kilowatts: 15)
  //     ),
  //     (
  //       "projectID=\(UUID(0))&capacityAt47=15&capacityAt17=14&heatPumpID=\(UUID(1))",
  //       HeatingInterpolation.Interpolation.heatPump(
  //         capacity: .init(capacityAt47: 15, capacityAt17: 14)
  //       )
  //     ),
  //   ]
  // )
  // func update(body: String, expected: HeatingInterpolation.Interpolation) throws {
  //   let request = URLRequestData(
  //     method: "POST", path: "/heating", body: .init(body.utf8))
  //   let sut = try router.match(request: .init(data: request)!)
  //   #expect(
  //     sut == .submit(.init(projectID: .init(UUID(0)), id: .init(UUID(1)), interpolation: expected))
  //   )
  // }
}

extension HeatingInterpolation.FormIntermediate {
  init(projectID: Project.ID, interpolation: HeatingInterpolation.Interpolation) {
    switch interpolation {
    case .boilerOrFurnace(let value):
      self.init(projectID: projectID, afue: value.afue, inputBTU: value.inputBTU, type: value.type)
    case .electric(let kw):
      self.init(projectID: projectID, kilowatts: Double(kw))
    case .heatPump(let capacity):
      self.init(
        projectID: projectID,
        capacityAt47: capacity.capacityAt47,
        capacityAt17: capacity.capacityAt17
      )
    }
  }

  init(
    projectID: Project.ID, id: HeatingInterpolation.ID,
    interpolation: HeatingInterpolation.Interpolation
  ) {
    switch interpolation {
    case .boilerOrFurnace(let value):
      self.init(projectID: projectID, afue: value.afue, inputBTU: value.inputBTU, type: value.type)
    case .electric(let kw):
      self.init(projectID: projectID, kilowatts: Double(kw))
    case .heatPump(let capacity):
      self.init(
        projectID: projectID,
        capacityAt47: capacity.capacityAt47,
        capacityAt17: capacity.capacityAt17
      )
    }
  }
}
