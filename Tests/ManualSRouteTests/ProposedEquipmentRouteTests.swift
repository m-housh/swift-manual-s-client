import Dependencies
import Foundation
import ManualSModels
import ManualSRouter
import Testing

@Suite
struct ProposedEquipmentRouteTests {

  @Test(
    arguments: [
      (
        equipmentManufacturers: ["one", "two"],
        equipmentModels: ["one", "two"],
        equipmentTypes: [ProposedEquipment.EquipmentType.airConditioner, .evaportorCoil]
      )
    ]
  )
  func formIntermediateConversions(
    equipmentManufacturers: [String],
    equipmentModels: [String],
    equipmentTypes: [ProposedEquipment.EquipmentType]
  ) throws {
    let create = try ProposedEquipment.FormIntermediate(
      projectID: .init(UUID(0)),
      equipmentManufacturers: equipmentManufacturers,
      equipmentModels: equipmentModels,
      equipmentTypes: equipmentTypes
    ).toCreate()

    #expect(
      create
        == .init(
          projectID: .init(UUID(0)),
          equipment: [
            .init(manufacturer: "one", model: "one", equipmentType: .airConditioner),
            .init(manufacturer: "two", model: "two", equipmentType: .evaportorCoil),
          ]
        )
    )

    let update = try ProposedEquipment.FormIntermediate(
      equipmentManufacturers: equipmentManufacturers,
      equipmentModels: equipmentModels,
      equipmentTypes: equipmentTypes
    ).toUpdate()

    #expect(
      update
        == .init(
          equipment: [
            .init(manufacturer: "one", model: "one", equipmentType: .airConditioner),
            .init(manufacturer: "two", model: "two", equipmentType: .evaportorCoil),
          ]
        )
    )

  }

  @Test(
    arguments: [
      (
        equipmentManufacturers: ["one", "two"],
        equipmentModels: ["one"],
        equipmentTypes: [ProposedEquipment.EquipmentType.airConditioner, .evaportorCoil]
      ),
      (
        equipmentManufacturers: ["one"],
        equipmentModels: ["one", "two"],
        equipmentTypes: [ProposedEquipment.EquipmentType.airConditioner, .evaportorCoil]
      ),
      (
        equipmentManufacturers: ["one", "two"],
        equipmentModels: ["one", "two"],
        equipmentTypes: [ProposedEquipment.EquipmentType.airConditioner]
      ),
    ]
  )
  func formIntermediateFails(
    equipmentManufacturers: [String],
    equipmentModels: [String],
    equipmentTypes: [ProposedEquipment.EquipmentType]
  ) throws {
    #expect(throws: (any Error).self) {
      try ProposedEquipment.FormIntermediate(
        projectID: .init(UUID(0)),
        equipmentManufacturers: equipmentManufacturers,
        equipmentModels: equipmentModels,
        equipmentTypes: equipmentTypes
      ).toCreate()
    }
    #expect(throws: (any Error).self) {
      try ProposedEquipment.FormIntermediate(
        equipmentManufacturers: equipmentManufacturers,
        equipmentModels: equipmentModels,
        equipmentTypes: equipmentTypes
      ).toUpdate()
    }
  }
}
