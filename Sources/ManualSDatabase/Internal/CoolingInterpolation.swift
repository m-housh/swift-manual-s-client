import Fluent
import Foundation
import ManualSModels
import SharedDatabase
import SharedModels
import Validations

extension ManualSDatabase.CoolingInterpolationRepository {
  public static func live(database: any Database) -> Self {
    .init(
      create: { request in
        let model = request.toModel()
        try await model.validateAndSave(on: database)
        return try model.toDTO()
      },
      delete: { id in
        guard let model = try await CoolingInterpolationModel.find(id, on: database) else {
          throw NotFoundError()
        }
        try await model.delete(on: database)
      },
      fetch: { projectID in
        try await CoolingInterpolationModel.query(on: database)
          .filter(\.$projectID == projectID.rawValue)
          .first()
          .map { try $0.toDTO() }
      },
      get: { id in
        try await CoolingInterpolationModel
          .find(id, on: database)
          .map { try $0.toDTO() }
      },
      update: { id, updates in
        guard let model = try await CoolingInterpolationModel.find(id, on: database) else {
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

extension CoolingInterpolation.Create {
  func toModel() -> CoolingInterpolationModel {
    .init(
      id: nil,
      projectID: projectID,
      interpolation: interpolation,
      manufacturersAdjustments: manufacturersAdjustments,
      designAirflow: designAirflow
    )
  }
}

extension CoolingInterpolation {
  struct Migrate: AsyncMigration {
    func prepare(on database: any Database) async throws {
      try await database.schema(CoolingInterpolationModel.schema)
        .id()
        .field("interpolation", .dictionary)
        .field("manufacturersAdjustments", .dictionary)
        .field("designAirflow", .int, .required)
        .field("createdAt", .string)
        .field("updatedAt", .string)
        .field("projectID", .uuid, .required, .references("project", "id", onDelete: .cascade))
        .unique(on: "projectID")
        .create()
    }

    func revert(on database: any Database) async throws {
      try await database.schema(CoolingInterpolationModel.schema).delete()
    }
  }
}

final class CoolingInterpolationModel: Model, @unchecked Sendable {

  static let schema = "coolingInterpolation"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "projectID")
  var projectID: UUID

  @Field(key: "designAirflow")
  var designAirflow: Int

  @Field(key: "interpolation")
  var interpolation: CoolingInterpolation.Interpolation

  @Field(key: "manufacturersAdjustments")
  var manufacturersAdjustments: CoolingCapacityAdjustment?

  @Timestamp(key: "createdAt", on: .create, format: .iso8601)
  var createdAt: Date?

  @Timestamp(key: "updatedAt", on: .update, format: .iso8601)
  var updatedAt: Date?

  init() {}

  public init(
    id: SystemType.ID? = nil,
    projectID: Project.ID,
    interpolation: CoolingInterpolation.Interpolation,
    manufacturersAdjustments: CoolingCapacityAdjustment?,
    designAirflow: Int
  ) {
    self.id = id?.rawValue
    self.projectID = projectID.rawValue
    self.interpolation = interpolation
    self.manufacturersAdjustments = manufacturersAdjustments
    self.designAirflow = designAirflow
  }

  func toDTO() throws -> CoolingInterpolation {
    .init(
      id: .init(try requireID()),
      projectID: .init(projectID),
      designAirflow: designAirflow,
      interpolation: interpolation,
      manufacturersAdjustemnts: manufacturersAdjustments,
      createdAt: createdAt!,
      updatedAt: updatedAt!
    )
  }

  func applyUpdates(_ updates: CoolingInterpolation.Update) {
    if updates.interpolation != self.interpolation {
      self.interpolation = updates.interpolation
    }
    if updates.manufacturersAdjustments != self.manufacturersAdjustments {
      self.manufacturersAdjustments = manufacturersAdjustments
    }
    if updates.designAirflow != self.designAirflow {
      self.designAirflow = designAirflow
    }
  }
}

extension CoolingInterpolationModel: Validatable {
  var body: some Validation<CoolingInterpolationModel> {
    Validator.validate(\.interpolation)
    Validator.validate(\.designAirflow, with: .greaterThan(0))
    Validator.validate(\.manufacturersAdjustments?.total.decimal) {
      Validator {
        Double.greaterThan(0)
        Double.lessThanOrEquals(1.0)
      }
      .optional()
    }
    Validator.validate(\.manufacturersAdjustments?.sensible.decimal) {
      Validator {
        Double.greaterThan(0)
        Double.lessThanOrEquals(1.0)
      }
      .optional()
    }
  }
}
