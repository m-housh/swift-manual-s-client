import Dependencies
import Foundation
import ManualSDatabase
import ManualSModels
import Testing

@Suite
struct DesignInfoTests {

  @Test
  func happyPath() async throws {
    try await withTestProject { project in
      @Dependency(\.database) var database

      let model = try await database.designInfo.create(
        .init(
          projectID: project.id,
          elevation: 0,
          summerOutdoorTemperature: 90,
          summerIndoorTemperature: 75,
          summerIndoorHumidity: 50,
          winterOutdoorTemperature: 5
        )
      )

      let fetched = try await database.designInfo.fetch(project.id)
      #expect(fetched == model)

      let got = try await database.designInfo.get(model.id)
      #expect(got == model)

      let updated = try await database.designInfo.update(model.id, .init(elevation: 800))
      #expect(updated.elevation == 800)

      try await database.designInfo.delete(model.id)

    }
  }

  @Test
  func unhappyPath() async throws {
    try await withTestDatabase {
      @Dependency(\.database) var database

      await #expect(throws: NotFoundError.self) {
        try await database.designInfo.delete(.init(UUID(0)))
      }

      await #expect(throws: NotFoundError.self) {
        try await database.designInfo.update(.init(UUID(0)), .init(elevation: 1234))
      }
    }
  }
}
