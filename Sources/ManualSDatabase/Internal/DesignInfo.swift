import Fluent
import Foundation
import ManualSModels
import SharedDatabase
import SharedModels
import Validations

extension ManualSDatabase.DesignInfoRepository {
  public static func live(database: any Database) -> Self {
    .init(
      create: { form in
        let model = form.toModel()
        try await model.validateAndSave(on: database)
        return try model.toDTO()
      },
      delete: { id in
        guard let model = try await DesignInfoModel.find(id, on: database) else {
          throw NotFoundError()
        }
        try await model.delete(on: database)
      },
      fetch: { projectID in
        try await DesignInfoModel.query(on: database)
          .filter(\.$projectID == projectID.rawValue)
          .first()
          .map { try $0.toDTO() }
      },
      get: { id in
        try await DesignInfoModel.find(id, on: database)
          .map { try $0.toDTO() }
      },
      update: { id, updates in
        guard let model = try await DesignInfoModel.find(id, on: database) else {
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

extension DesignInfo.Create {
  func toModel() -> DesignInfoModel {
    .init(
      projectID: projectID,
      elevation: elevation,
      summerOutdoorTemperature: summerOutdoorTemperature,
      summerIndoorTemperature: summerIndoorTemperature,
      summerIndoorHumidity: summerIndoorHumidity,
      winterOutdoorTemperature: winterOutdoorTemperature
    )
  }
}

extension DesignInfo {
  struct Migrate: AsyncMigration {

    func prepare(on database: any Database) async throws {
      try await database.schema(DesignInfoModel.schema)
        .id()
        .field("elevation", .int, .required)
        .field("summerOutdoorTemperature", .int, .required)
        .field("summerIndoorTemperature", .int, .required)
        .field("summerIndoorHumidity", .double, .required)
        .field("winterOutdoorTemperature", .int, .required)
        .field("createdAt", .string)
        .field("updatedAt", .string)
        .field("projectID", .uuid, .required, .references("project", "id", onDelete: .cascade))
        .unique(on: "projectID")
        .create()
    }

    func revert(on database: any Database) async throws {
      try await database.schema(DesignInfoModel.schema).delete()
    }
  }
}

final class DesignInfoModel: Model, @unchecked Sendable {

  static let schema = "designInfo"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "projectID")
  var projectID: UUID

  @Field(key: "elevation")
  var elevation: Int

  @Field(key: "summerOutdoorTemperature")
  var summerOutdoorTemperature: Int

  @Field(key: "summerIndoorTemperature")
  var summerIndoorTemperature: Int

  @Field(key: "summerIndoorHumidity")
  var summerIndoorHumidity: Double

  @Field(key: "winterOutdoorTemperature")
  var winterOutdoorTemperature: Int

  @Timestamp(key: "createdAt", on: .create, format: .iso8601)
  var createdAt: Date?

  @Timestamp(key: "updatedAt", on: .update, format: .iso8601)
  var updatedAt: Date?

  init() {}

  init(
    id: DesignInfo.ID? = nil,
    projectID: Project.ID,
    elevation: Int,
    summerOutdoorTemperature: Int,
    summerIndoorTemperature: Int,
    summerIndoorHumidity: Percent,
    winterOutdoorTemperature: Int
  ) {
    self.id = id?.rawValue
    self.projectID = projectID.rawValue
    self.elevation = elevation
    self.summerOutdoorTemperature = summerOutdoorTemperature
    self.summerIndoorTemperature = summerIndoorTemperature
    self.summerIndoorHumidity = summerIndoorHumidity.rawValue
    self.winterOutdoorTemperature = winterOutdoorTemperature
  }

  func toDTO() throws -> DesignInfo {
    .init(
      id: .init(try requireID()),
      projectID: .init(projectID),
      elevation: elevation,
      summerOutdoorTemperature: summerOutdoorTemperature,
      summerIndoorTemperature: summerIndoorTemperature,
      summerIndoorHumidity: .init(rawValue: summerIndoorHumidity),
      winterOutdoorTemperature: winterOutdoorTemperature,
      createdAt: createdAt!,
      updatedAt: updatedAt!
    )
  }

  func applyUpdates(_ updates: DesignInfo.Update) {
    if let elevation = updates.elevation, elevation != self.elevation {
      self.elevation = elevation
    }
    if let summerOutdoorTemperature = updates.summerOutdoorTemperature,
      summerOutdoorTemperature != self.summerOutdoorTemperature
    {
      self.summerOutdoorTemperature = summerOutdoorTemperature
    }
    if let summerIndoorTemperature = updates.summerIndoorTemperature,
      summerIndoorTemperature != self.summerIndoorTemperature
    {
      self.summerIndoorTemperature = summerIndoorTemperature
    }
    if let summerIndoorHumidity = updates.summerIndoorHumidity,
      summerIndoorHumidity.rawValue != self.summerIndoorHumidity
    {
      self.summerIndoorHumidity = summerIndoorHumidity.rawValue
    }
    if let winterOutdoorTemperature = updates.winterOutdoorTemperature,
      self.winterOutdoorTemperature != winterOutdoorTemperature
    {
      self.winterOutdoorTemperature = winterOutdoorTemperature
    }
  }
}

extension DesignInfoModel: Validatable {

  var body: some Validation<DesignInfoModel> {
    Validator.accumulating {
      Validator.validate(\.elevation, with: .greaterThanOrEquals(0))
        .errorLabel("elevation", inline: true)

      Validator.validate(\.summerOutdoorTemperature, with: .greaterThanOrEquals(0))
        .errorLabel("summerOutdoorTemperature", inline: true)

      Validator.validate(\.summerIndoorTemperature, with: .greaterThanOrEquals(0))
        .errorLabel("summerIndoorTemperature", inline: true)

      Validator.validate(\.summerIndoorHumidity, with: .greaterThanOrEquals(0))
        .errorLabel("summerIndoorHumidity", inline: true)
    }
  }
}
