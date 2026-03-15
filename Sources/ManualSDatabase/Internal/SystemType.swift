import Fluent
import Foundation
import ManualSModels
import SharedDatabase
import Validations

extension ManualSDatabase.SystemTypeRepository {
  public static func live(database: any Database) -> Self {
    .init(
      create: { request in
        let model = request.toModel()
        try await model.save(on: database)
        return try model.toDTO()
      },
      delete: { id in
        guard let model = try await SystemTypeModel.find(id, on: database) else {
          throw NotFoundError()
        }
        try await model.delete(on: database)
      },
      fetch: { projectID in
        try await SystemTypeModel.query(on: database)
          .filter(\.$project.$id == projectID.rawValue)
          .first()
          .map { try $0.toDTO() }
      },
      get: { id in
        try await SystemTypeModel
          .find(id, on: database)
          .map { try $0.toDTO() }
      },
      update: { id, updates in
        guard let model = try await SystemTypeModel.find(id, on: database) else {
          throw NotFoundError()
        }
        model.applyUpdates(updates)
        if model.hasChanges {
          try await model.save(on: database)
        }
        return try model.toDTO()
      }
    )
  }
}

extension SystemType.Create {
  func toModel() -> SystemTypeModel {
    .init(
      id: nil,
      projectID: projectID,
      cooling: cooling,
      heating: heating
    )
  }
}

extension SystemType {
  struct Migrate: AsyncMigration {
    func prepare(on database: any Database) async throws {
      try await database.schema(SystemTypeModel.schema)
        .id()
        .field("cooling", .dictionary)
        .field("heating", .string)
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
      try await database.schema(SystemTypeModel.schema).delete()
    }
  }
}

final class SystemTypeModel: Model, @unchecked Sendable {

  static let schema = "systemType"

  @ID(key: .id)
  var id: UUID?

  @Parent(key: "projectID")
  var project: ProjectModel

  @Field(key: "cooling")
  var cooling: SystemType.Cooling?

  @Field(key: "heating")
  var heating: String?

  @Timestamp(key: "createdAt", on: .create, format: .iso8601)
  var createdAt: Date?

  @Timestamp(key: "updatedAt", on: .update, format: .iso8601)
  var updatedAt: Date?

  init() {}

  public init(
    id: SystemType.ID? = nil,
    projectID: Project.ID,
    cooling: SystemType.Cooling? = nil,
    heating: SystemType.Heating? = nil
  ) {
    self.id = id?.rawValue
    self.$project.id = projectID.rawValue
    self.cooling = cooling
    self.heating = heating?.rawValue
  }

  func toDTO() throws -> SystemType {
    .init(
      id: .init(try requireID()),
      projectID: .init($project.id),
      cooling: cooling,
      heating: heating.flatMap(SystemType.Heating.init(rawValue:)),
      createdAt: createdAt!,
      updatedAt: updatedAt!
    )
  }

  func applyUpdates(_ updates: SystemType.Update) {
    if let cooling = updates.cooling, cooling != self.cooling {
      self.cooling = cooling
    }
    if let heating = updates.heating, heating.rawValue != self.heating {
      self.heating = heating.rawValue
    }
  }
}
