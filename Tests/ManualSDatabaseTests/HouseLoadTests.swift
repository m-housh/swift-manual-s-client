import Dependencies
import Foundation
import ManualSDatabase
import ManualSModels
import SharedDatabase
import Testing

@Suite
struct HouseLoadTests {

  @Test
  func happyPath() async throws {
    try await withTestProject { project in
      @Dependency(\.database) var database

      let model = try await database.houseLoads.create(
        .init(projectID: project.id, heating: 1234, coolingTotal: 1234, coolingSensible: 1234)
      )

      let fetched = try await database.houseLoads.fetch(project.id)
      #expect(fetched == model)

      let got = try await database.houseLoads.get(model.id)
      #expect(got == model)

      let updated = try await database.houseLoads.update(model.id, .init(heating: 1222))
      #expect(updated.heating == 1222)

      try await database.houseLoads.delete(model.id)
    }
  }

  @Test
  func unhappyPath() async throws {
    try await withTestDatabase {
      @Dependency(\.database) var database

      await #expect(throws: NotFoundError.self) {
        try await database.houseLoads.delete(.init(UUID(0)))
      }

      await #expect(throws: NotFoundError.self) {
        try await database.houseLoads.update(.init(UUID(0)), .init(heating: 1234))
      }
    }
  }

}
