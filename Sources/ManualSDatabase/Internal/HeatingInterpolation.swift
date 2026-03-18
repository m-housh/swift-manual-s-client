import Fluent
import Foundation
import ManualSModels
import SharedDatabase
import SharedModels
import Validations

extension ManualSDatabase.HeatingInterpolationRepository {
  public static func live(database: any Database) -> Self {
    .init(
      create: { requests in
        var models: [HeatingInterpolation] = []
        for request in requests {
          let model = request.toModel()
          try await model.validateAndSave(on: database)
          models.append(try model.toDTO())
        }
        return models
      },
      delete: { id in
        guard let model = try await HeatingInterpolationModel.find(id, on: database) else {
          throw NotFoundError()
        }
        try await model.delete(on: database)
      },
      fetch: { projectID in
        try await HeatingInterpolationModel.query(on: database)
          .filter(\.$project.$id == projectID.rawValue)
          .all()
          .map { try $0.toDTO() }
      },
      get: { id in
        try await HeatingInterpolationModel
          .find(id, on: database)
          .map { try $0.toDTO() }
      },
      update: { updates in
        var models = [HeatingInterpolation]()
        for (id, update) in updates {
          guard let model = try await HeatingInterpolationModel.find(id, on: database) else {
            throw NotFoundError()
          }
          model.applyUpdates(update)
          if model.hasChanges {
            try await model.validateAndSave(on: database)
          }
          models.append(try model.toDTO())
        }
        return models
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
        .field("interpolationType", .string, .required)
        .field("createdAt", .string)
        .field("updatedAt", .string)
        .field(
          "projectID", .uuid, .required,
          .references(ProjectModel.schema, "id", onDelete: .cascade)
        )
        .unique(on: "projectID", "interpolationType")
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

  @Parent(key: "projectID")
  var project: ProjectModel

  @Field(key: "interpolation")
  var interpolation: HeatingInterpolation.Interpolation

  @Field(key: "interpolationType")
  var interpolationType: String

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
    self.$project.id = projectID.rawValue
    self.interpolation = interpolation
    self.interpolationType = interpolation.interpolationType.rawValue
  }

  func toDTO() throws -> HeatingInterpolation {
    .init(
      id: .init(try requireID()),
      projectID: .init($project.id),
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

  // Used for unique constraint, so that only one interpolation per
  // project.
  enum InterpolationType: String {
    case boilerOrFurnace
    case electric
    case heatPump
  }
}

extension HeatingInterpolation.Interpolation {
  fileprivate var interpolationType: HeatingInterpolationModel.InterpolationType {
    switch self {
    case .boilerOrFurnace: return .boilerOrFurnace
    case .electric: return .electric
    case .heatPump: return .heatPump
    }
  }
}

extension HeatingInterpolationModel: Validatable {
  var body: some Validation<HeatingInterpolationModel> {
    Validator.validate(\.interpolation)
  }
}
