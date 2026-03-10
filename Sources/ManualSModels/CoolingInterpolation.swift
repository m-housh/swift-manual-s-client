import CasePaths
import Foundation
import SharedModels
import Tagged
import Validations

public struct CoolingInterpolation: Codable, Equatable, Identifiable, Sendable {

  public let id: Tagged<Self, UUID>
  public let projectID: Project.ID
  public let interpolation: Interpolation
  public let createdAt: Date
  public let updatedAt: Date

  public init(
    id: Tagged<CoolingInterpolation, UUID>,
    projectID: Project.ID,
    interpolation: CoolingInterpolation.Interpolation,
    createdAt: Date,
    updatedAt: Date
  ) {
    self.id = id
    self.projectID = projectID
    self.interpolation = interpolation
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }

  public struct Response: Codable, Equatable, Sendable {
    public typealias CapacityAsPercentOfLoad = Tagged<
      TSLTag.CapacityAsPercentOfLoad, TSLContainer<Percent>
    >

    public let interpolatedCapacity: CoolingCapacity
    public let excessLatent: Double
    public let finalCapacityAtDesign: CoolingCapacity
    public let altitudeDeratings: CoolingDerating?
    public let capacityAsPercentOfLoad: CapacityAsPercentOfLoad

    public init(
      interpolatedCapacity: CoolingCapacity,
      excessLatent: Double,
      finalCapacityAtDesign: CoolingCapacity,
      altitudeDeratings: CoolingDerating? = nil,
      capacityAsPercentOfLoad: CapacityAsPercentOfLoad
    ) {
      self.interpolatedCapacity = interpolatedCapacity
      self.excessLatent = excessLatent
      self.finalCapacityAtDesign = finalCapacityAtDesign
      self.altitudeDeratings = altitudeDeratings
      self.capacityAsPercentOfLoad = capacityAsPercentOfLoad
    }
  }

  public struct Request: Codable, Equatable, Sendable {

    public let coolingLoad: CoolingLoad
    public let manufacturersAdjustments: CoolingCapacityAdjustment?
    public let outdoorDesignTemperature: Int
    public let projectElevation: Int
    public let interpolation: CoolingInterpolation.Interpolation

    public init(
      coolingLoad: CoolingLoad,
      manufacturersAdjustments: CoolingCapacityAdjustment? = nil,
      outdoorDesignTemperature: Int,
      projectElevation: Int = 0,
      interpolation: CoolingInterpolation.Interpolation
    ) {
      self.coolingLoad = coolingLoad
      self.manufacturersAdjustments = manufacturersAdjustments
      self.outdoorDesignTemperature = outdoorDesignTemperature
      self.projectElevation = projectElevation
      self.interpolation = interpolation
    }
  }

  @CasePathable
  @dynamicMemberLookup
  public enum Interpolation: Codable, Equatable, Sendable {
    case noInterpolation(CoolingCapacity)
    case oneWayIndoor(OneWayIndoor)
    case oneWayOutdoor(OneWayOutdoor)
    case twoWay(TwoWay)

    public static func noInterpolation(total: Double, sensible: Double) -> Self {
      .noInterpolation(.init(total: total, sensible: sensible))
    }

    public struct OneWayOutdoor: Codable, Equatable, Sendable {

      public let aboveDesign: Envelope
      public let belowDesign: Envelope

      public init(
        aboveDesign: Self.Envelope,
        belowDesign: Self.Envelope
      ) {
        self.aboveDesign = aboveDesign
        self.belowDesign = belowDesign
      }

      public struct Envelope: Codable, Equatable, Sendable {

        public let outdoorTemperature: Int
        public let capacity: CoolingCapacity

        public init(outdoorTemperature: Int, capacity: CoolingCapacity) {
          self.outdoorTemperature = outdoorTemperature
          self.capacity = capacity
        }
      }
    }

    public struct OneWayIndoor: Codable, Equatable, Sendable {

      public let aboveDesign: Envelope
      public let belowDesign: Envelope

      public init(
        aboveDesign: Self.Envelope,
        belowDesign: Self.Envelope
      ) {
        self.aboveDesign = aboveDesign
        self.belowDesign = belowDesign
      }

      public struct Envelope: Codable, Equatable, Sendable {

        public let indoorWetBulbTemperature: Int
        public let capacity: CoolingCapacity

        public init(indoorWetBulbTemperature: Int, capacity: CoolingCapacity) {
          self.indoorWetBulbTemperature = indoorWetBulbTemperature
          self.capacity = capacity
        }
      }
    }

    public struct TwoWay: Codable, Equatable, Sendable {

      public let aboveDesign: Envelope
      public let belowDesign: Envelope

      public init(
        aboveDesign: Envelope,
        belowDesign: Envelope
      ) {
        self.aboveDesign = aboveDesign
        self.belowDesign = belowDesign
      }

      public struct Envelope: Codable, Equatable, Sendable {

        public let outdoorTemperature: Int
        public let aboveWetBulb: OneWayIndoor.Envelope
        public let belowWetBulb: OneWayIndoor.Envelope

        public init(
          outdoorTemperature: Int,
          aboveWetBulb: CoolingInterpolation.Interpolation.OneWayIndoor.Envelope,
          belowWetBulb: CoolingInterpolation.Interpolation.OneWayIndoor.Envelope
        ) {
          self.outdoorTemperature = outdoorTemperature
          self.aboveWetBulb = aboveWetBulb
          self.belowWetBulb = belowWetBulb
        }
      }
    }
  }

}
extension CoolingInterpolation {
  public struct Create: Codable, Equatable, Sendable {
    public let projectID: Project.ID
    public let interpolation: Interpolation

    public init(
      projectID: Project.ID,
      interpolation: CoolingInterpolation.Interpolation,
    ) {
      self.projectID = projectID
      self.interpolation = interpolation
    }
  }

  public struct Update: Codable, Equatable, Sendable {
    public let interpolation: Interpolation

    public init(
      interpolation: CoolingInterpolation.Interpolation
    ) {
      self.interpolation = interpolation
    }
  }
}

// MARK: Validations

extension CoolingContainer: Validatable where N == Double {

  public var body: some Validation<Self> {
    Validator.accumulating {
      Validator.validate(\.total, with: .greaterThan(0))
        .errorLabel("total", inline: true)

      Validator.accumulating {
        Validator.validate(\.sensible, with: .greaterThan(0))
        Validator.lessThanOrEquals(\.sensible, \.total)
      }
      .errorLabel("sensible", inline: true)

    }
  }
}
extension CoolingContainer: Validation where N == Double {}

extension CoolingInterpolation.Interpolation: Validatable {

  public var body: some Validation<Self> {
    Validator.oneOf {
      Validator.case(\.noInterpolation)
      Validator.case(\.oneWayOutdoor)
      Validator.case(\.oneWayIndoor)
      Validator.case(\.twoWay)
    }
  }
}

extension CoolingInterpolation.Interpolation.OneWayOutdoor.Envelope: Validatable {
  public var body: some Validation<Self> {
    Validator.validate(\.capacity)
  }
}

extension CoolingInterpolation.Interpolation.OneWayOutdoor: Validatable {

  public var body: some Validation<Self> {
    Validator.accumulating {
      Validator.validate(\.aboveDesign)
      Validator.validate(\.belowDesign)
      Validator.greaterThan(\.aboveDesign.outdoorTemperature, \.belowDesign.outdoorTemperature)
        .errorLabel("outdoorTemperature", inline: true)
    }
  }
}

extension CoolingInterpolation.Interpolation.OneWayIndoor.Envelope: Validatable {
  public var body: some Validation<Self> {
    Validator.validate(\.capacity)
  }
}
extension CoolingInterpolation.Interpolation.OneWayIndoor: Validatable {
  public var body: some Validation<Self> {
    Validator.accumulating {
      Validator.validate(\.aboveDesign)
      Validator.validate(\.belowDesign)
      Validator.greaterThan(
        \.aboveDesign.indoorWetBulbTemperature, \.belowDesign.indoorWetBulbTemperature
      )
      .errorLabel("wetBulb", inline: true)
    }
  }
}

extension CoolingInterpolation.Interpolation.TwoWay.Envelope: Validatable {
  public var body: some Validation<Self> {
    Validator.accumulating {
      Validator.validate(\.outdoorTemperature, with: .greaterThan(0))
      Validator.validate(\.aboveWetBulb)
      Validator.validate(\.belowWetBulb)
      Validator.greaterThan(
        \.aboveWetBulb.indoorWetBulbTemperature, \.belowWetBulb.indoorWetBulbTemperature
      )
      .errorLabel("wetBulb", inline: true)
    }
  }
}

extension CoolingInterpolation.Interpolation.TwoWay: Validatable {
  public var body: some Validation<Self> {
    Validator.accumulating {
      Validator.validate(\.aboveDesign)
      Validator.validate(\.belowDesign)
      Validator.greaterThan(\.aboveDesign.outdoorTemperature, \.belowDesign.outdoorTemperature)
        .errorLabel("outdoorTemperature", inline: true)
    }
  }
}

// MARK: Mocks

#if DEBUG
  extension CoolingInterpolation.Response {
    public static let mock = Self(
      interpolatedCapacity: .init(total: 23456, sensible: 17865),
      excessLatent: 807,
      finalCapacityAtDesign: .init(total: 23456, sensible: 17865),
      altitudeDeratings: .init(total: 100, sensible: 100),
      capacityAsPercentOfLoad: .init(total: 131.2, sensible: 134.4, latent: 120.3)
    )
  }
#endif
