import Dependencies
import Foundation
import ManualSModels
import ManualSRouter
import Testing
import URLRouting

@Suite
struct SystemTypeRouteTests {

  let router = ManualSRoute.router

  @Test
  func coolingForm() throws {
    let request = URLRequestData(
      method: "POST",
      path: "/projects/\(UUID(0))/system-type",
      body: .init(
        "projectID=\(UUID(0))&equipment=airConditioner&compressor=singleSpeed&climate=mildWinterOrLatentLoad"
          .utf8
      )
    )
    let sut = try router.match(request: .init(data: request)!)
    #expect(
      sut
        == .projectDetail(
          .init(UUID(0)),
          .systemTypes(
            .submit(
              .init(
                projectID: .init(UUID(0)),
                cooling: .init(
                  equipment: .airConditioner, compressor: .singleSpeed,
                  climate: .mildWinterOrLatentLoad)))))
    )
  }
}
