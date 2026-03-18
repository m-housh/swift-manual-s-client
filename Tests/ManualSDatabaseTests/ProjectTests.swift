import Dependencies
import ManualSDatabase
import ManualSModels
import Testing

@Suite
struct ProjectDatabaseTests {

  @Test func fetchDetails() async throws {
    try await withTestProject { project in
      @Dependency(\.database) var database

      let emptyDetails = try await database.projects.fetchDetails(project.id)
      #expect(emptyDetails == .init(project: project))

      let designInfo = try await database.designInfo.create(
        .init(
          projectID: project.id, elevation: 0, summerOutdoorTemperature: 95,
          summerIndoorTemperature: 75, summerIndoorHumidity: 50, winterOutdoorTemperature: 5)
      )
      let houseLoad = try await database.houseLoads.create(
        .init(projectID: project.id, heating: 12345, coolingTotal: 12345, coolingSensible: 12345)
      )
      let coolingInterpolation = try await database.coolingInterpolations.create(
        .init(
          projectID: project.id, designAirflow: 900,
          interpolation: .noInterpolation(total: 12345, sensible: 12345),
          manufacturersAdjustments: nil)
      )
      let proposedEquipment = try await database.proposedEquipment.create(
        .init(
          projectID: project.id,
          equipment: [.init(manufacturer: "Test", model: "Test", equipmentType: .airConditioner)])
      )
      let systemType = try await database.systemTypes.create(
        .init(projectID: project.id, cooling: .mock, heating: .furnace)
      )
      let heatingInterpolation = try await database.heatingInterpolations.create(
        .init(projectID: project.id, interpolation: .electric(kilowatts: 12345))
      )

      let fullDetails = try await database.projects.fetchDetails(project.id)
      let expected = Project.Details(
        project: project,
        designInfo: designInfo,
        systemType: systemType,
        proposedEquipment: proposedEquipment,
        houseLoad: houseLoad,
        coolingInterpolation: coolingInterpolation,
        heatingInterpolations: [heatingInterpolation]
      )

      #expect(fullDetails == expected)

    }
  }
}
