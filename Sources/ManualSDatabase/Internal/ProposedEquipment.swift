import Fluent
import Foundation
import ManualSModels
import SharedDatabase
import SharedModels
import Validations

extension ManualSDatabase.ProposedEquipmentRepository {
  public static func live(database: any Database) -> Self {
    .init(
      create: { request in
        let model = request.toModel()
        try await model.validateAndSave(on: database)
        return try model.toDTO()
      },
      delete: { id in
        guard let model = try await ProposedEquipmentModel.find(id, on: database) else {
          throw NotFoundError()
        }
        try await model.delete(on: database)
      },
      fetch: { projectID in
        try await ProposedEquipmentModel.query(on: database)
          .filter(\.$project.$id == projectID.rawValue)
          .first()
          .map { try $0.toDTO() }
      },
      get: { id in
        try await ProposedEquipmentModel
          .find(id, on: database)
          .map { try $0.toDTO() }
      },
      update: { id, updates in
        guard let model = try await ProposedEquipmentModel.find(id, on: database) else {
          throw NotFoundError()
        }
        model.applyUpdates(updates)
        if model.hasChanges {
          try await model.validateAndSave(on: database)
        }
        return try model.toDTO()
      }
    )
  }
}

extension ProposedEquipment.Create {
  func toModel() -> ProposedEquipmentModel {
    ProposedEquipmentModel(
      id: nil,
      projectID: projectID,
      afue: afue,
      seer: seer,
      hspf: hspf,
      fanSpeed: fanSpeed,
      equipment: equipment
    )
  }
}

extension ProposedEquipment {
  struct Migrate: AsyncMigration {
    func prepare(on database: any FluentKit.Database) async throws {
      try await database.schema(ProposedEquipmentModel.schema)
        .id()
        .field("afue", .double)
        .field("seer", .double)
        .field("hspf", .double)
        .field("fanSpeed", .string)
        .field("equipment", .array)
        .field("createdAt", .string)
        .field("updatedAt", .string)
        .field(
          "projectID", .uuid, .required,
          .references(ProjectModel.schema, "id", onDelete: .cascade)
        )
        .unique(on: "projectID")
        .create()
    }

    func revert(on database: any FluentKit.Database) async throws {
      try await database.schema(ProposedEquipmentModel.schema).delete()
    }
  }
}

final class ProposedEquipmentModel: Model, @unchecked Sendable {

  static let schema = "proposedEquipment"

  @ID(key: .id)
  var id: UUID?

  @Parent(key: "projectID")
  var project: ProjectModel

  @Field(key: "afue")
  var afue: Double?

  @Field(key: "seer")
  var seer: Double?

  @Field(key: "hspf")
  var hspf: Double?

  @Field(key: "fanSpeed")
  var fanSpeed: String?

  @Field(key: "equipment")
  var equipment: [ProposedEquipment.Equipment]

  @Timestamp(key: "createdAt", on: .create, format: .iso8601)
  var createdAt: Date?

  @Timestamp(key: "updatedAt", on: .update, format: .iso8601)
  var updatedAt: Date?

  init() {}

  public init(
    id: UUID? = nil,
    projectID: Project.ID,
    afue: Percent? = nil,
    seer: Double? = nil,
    hspf: Double? = nil,
    fanSpeed: ProposedEquipment.FanSpeed? = nil,
    equipment: [ProposedEquipment.Equipment]
  ) {
    self.id = id
    self.$project.id = projectID.rawValue
    self.afue = afue?.rawValue
    self.seer = seer
    self.hspf = hspf
    self.fanSpeed = fanSpeed?.rawValue
    self.equipment = equipment
  }

  func toDTO() throws -> ProposedEquipment {
    .init(
      id: .init(try requireID()),
      projectID: .init($project.id),
      afue: afue.map(Percent.init(rawValue:)),
      seer: seer,
      hspf: hspf,
      fanSpeed: fanSpeed.flatMap(ProposedEquipment.FanSpeed.init(rawValue:)),
      equipment: equipment,
      createdAt: createdAt!,
      updatedAt: updatedAt!
    )
  }

  func applyUpdates(_ updates: ProposedEquipment.Update) {
    if let afue = updates.afue, afue.rawValue != self.afue {
      self.afue = afue.rawValue
    }
    if let seer = updates.seer, seer != self.seer {
      self.seer = seer
    }
    if let hspf = updates.hspf, hspf != self.hspf {
      self.hspf = hspf
    }
    if let fanSpeed = updates.fanSpeed, fanSpeed.rawValue != self.fanSpeed {
      self.fanSpeed = fanSpeed.rawValue
    }
    if let equipment = updates.equipment, equipment != self.equipment {
      self.equipment = equipment
    }
  }
}

extension ProposedEquipmentModel: Validatable {

  var body: some Validation<ProposedEquipmentModel> {
    Validator.accumulating {
      Validator.validate(\.afue, with: Double.greaterThanOrEquals(0).optional())
      Validator.validate(\.seer, with: Double.greaterThanOrEquals(0).optional())
      Validator.validate(\.hspf, with: Double.greaterThanOrEquals(0).optional())
    }
  }
}
