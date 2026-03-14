import Fluent
import Foundation
import ManualSModels
import SharedDatabase
import SharedModels
import Validations

extension ManualSDatabase.HeatingInterpolationRepository {
  public static func live(database: any Database) -> Self {
    .init(
      create: { request in
        let model = request.toModel()
        try await model.validateAndSave(on: database)
        return try model.toDTO()
      },
      delete: { id in
        guard let model = try await HeatingInterpolationModel.find(id, on: database) else {
          throw NotFoundError()
        }
        try await model.delete(on: database)
      },
      fetch: { projectID in
        try await HeatingInterpolationModel.query(on: database)
          .filter(\.$projectID == projectID.rawValue)
          .all()
          .map { try $0.toDTO() }
      },
      get: { id in
        try await HeatingInterpolationModel
          .find(id, on: database)
          .map { try $0.toDTO() }
      },
      update: { id, updates in
        guard let model = try await HeatingInterpolationModel.find(id, on: database) else {
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

extension HeatingInterpolation.Create {
  func toModel() -> HeatingInterpolationModel {
    .init(
      id: nil,
      projectID: projectID,
      interpolation: interpolation
    )
  }
}

extension HeatingInterpolation {
  struct Migrate: AsyncMigration {
    func prepare(on database: any Database) async throws {
      try await database.schema(HeatingInterpolationModel.schema)
        .id()
        .field("interpolation", .dictionary)
        .field("createdAt", .string)
        .field("updatedAt", .string)
        .field("projectID", .uuid, .required, .references("project", "id", onDelete: .cascade))
        .create()
    }

    func revert(on database: any Database) async throws {
      try await database.schema(HeatingInterpolationModel.schema).delete()
    }
  }
}

final class HeatingInterpolationModel: Model, @unchecked Sendable {

  static let schema = "heatingInterpolation"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "projectID")
  var projectID: UUID

  @Field(key: "interpolation")
  var interpolation: HeatingInterpolation.Interpolation

  @Timestamp(key: "createdAt", on: .create, format: .iso8601)
  var createdAt: Date?

  @Timestamp(key: "updatedAt", on: .update, format: .iso8601)
  var updatedAt: Date?

  init() {}

  public init(
    id: SystemType.ID? = nil,
    projectID: Project.ID,
    interpolation: HeatingInterpolation.Interpolation
  ) {
    self.id = id?.rawValue
    self.projectID = projectID.rawValue
    self.interpolation = interpolation
  }

  func toDTO() throws -> HeatingInterpolation {
    .init(
      id: .init(try requireID()),
      projectID: .init(projectID),
      interpolation: interpolation,
      createdAt: createdAt!,
      updatedAt: updatedAt!
    )
  }

  func applyUpdates(_ updates: HeatingInterpolation.Update) {
    if updates.interpolation != self.interpolation {
      self.interpolation = updates.interpolation
    }
  }
}

extension HeatingInterpolationModel: Validatable {
  var body: some Validation<HeatingInterpolationModel> {
    Validator.validate(\.interpolation)
  }
}
