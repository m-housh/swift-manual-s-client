import Fluent
import Foundation
import ManualSModels
import SharedDatabase
import Validations

extension ManualSDatabase.HouseLoads {
  static func live(database: any Database) -> Self {
    Self(
      create: { model in
        let model = model.toModel()
        try await model.validateAndSave(on: database)
        return try model.toDTO()
      },
      delete: { id in
        guard let model = try await HouseLoadModel.find(id, on: database) else {
          throw NotFoundError()
        }
        try await model.delete(on: database)
      },
      fetch: { projectID in
        try await HouseLoadModel.query(on: database)
          .filter(\.$project.$id == projectID.rawValue)
          .first()
          .map { try $0.toDTO() }
      },
      get: { id in
        try await HouseLoadModel.find(id.rawValue, on: database)
          .map { try $0.toDTO() }
      },
      update: { id, updates in
        guard let model = try await HouseLoadModel.find(id, on: database) else {
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

extension HouseLoad.Create {
  func toModel() -> HouseLoadModel {
    .init(
      projectID: projectID,
      heating: heating,
      coolingTotal: coolingTotal,
      coolingSensible: coolingSensible
    )
  }
}
extension HouseLoad {
  struct Migrate: AsyncMigration {

    func prepare(on database: any Database) async throws {
      try await database.schema(HouseLoadModel.schema)
        .id()
        .field("heating", .double, .required)
        .field("coolingTotal", .double, .required)
        .field("coolingSensible", .double, .required)
        .field("createdAt", .string)
        .field("updatedAt", .string)
        .field(
          "projectID", .uuid, .required,
          .references(ProjectModel.schema, "id", onDelete: .cascade)
        )
        .unique(on: "projectID")
        .create()
    }

    func revert(on database: any Database) async throws {
      try await database.schema(HouseLoadModel.schema).delete()
    }
  }
}

final class HouseLoadModel: Fluent.Model, @unchecked Sendable {
  static let schema = "houseLoad"

  @ID(key: .id)
  var id: UUID?

  @Parent(key: "projectID")
  var project: ProjectModel

  @Field(key: "heating")
  var heating: Double

  @Field(key: "coolingTotal")
  var coolingTotal: Double

  @Field(key: "coolingSensible")
  var coolingSensible: Double

  @Timestamp(key: "createdAt", on: .create, format: .iso8601)
  var createdAt: Date?

  @Timestamp(key: "updatedAt", on: .update, format: .iso8601)
  var updatedAt: Date?

  init() {}

  init(
    id: HouseLoad.ID? = nil,
    projectID: Project.ID,
    heating: Double,
    coolingTotal: Double,
    coolingSensible: Double,
  ) {
    self.id = id?.rawValue
    self.$project.id = projectID.rawValue
    self.heating = heating
    self.coolingTotal = coolingTotal
    self.coolingSensible = coolingSensible
  }

  func toDTO() throws -> HouseLoad {
    .init(
      id: .init(try requireID()),
      projectID: .init($project.id),
      heating: heating,
      cooling: .init(total: coolingTotal, sensible: coolingSensible),
      createdAt: createdAt!,
      updatedAt: updatedAt!
    )
  }

  func applyUpdates(_ updates: HouseLoad.Update) {
    if let heating = updates.heating, heating != self.heating {
      self.heating = heating
    }
    if let coolingTotal = updates.coolingTotal, coolingTotal != self.coolingTotal {
      self.coolingTotal = coolingTotal
    }
    if let coolingSensible = updates.coolingSensible, coolingSensible != self.coolingSensible {
      self.coolingSensible = coolingSensible
    }
  }
}

extension HouseLoadModel: Validations.Validatable {

  var body: some Validations.Validation<HouseLoadModel> {
    Validator.accumulating {
      Validator.validate(\.heating, with: .greaterThanOrEquals(0))
        .errorLabel("heating", inline: true)

      Validator.validate(\.coolingTotal, with: .greaterThanOrEquals(0))
        .errorLabel("coolingTotal", inline: true)

      Validator.validate(\.coolingSensible, with: .greaterThanOrEquals(0))
        .errorLabel("coolingSensible", inline: true)
    }
  }
}
