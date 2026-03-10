import CasePaths
import Foundation
import SharedModels
import Tagged
import Validations

// TODO: Do we need to return size limits??
public struct HeatingInterpolation: Codable, Equatable, Identifiable, Sendable {

  public let id: Tagged<Self, UUID>
  public let projectID: Project.ID
  public let interpolations: [Interpolation]
  public let createdAt: Date
  public let updatedAt: Date

  public init(
    id: Tagged<HeatingInterpolation, UUID>,
    projectID: Project.ID,
    interpolations: [HeatingInterpolation.Interpolation],
    createdAt: Date,
    updatedAt: Date
  ) {
    self.id = id
    self.projectID = projectID
    self.interpolations = interpolations
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }

  @CasePathable
  @dynamicMemberLookup
  public enum Interpolation: Codable, Equatable, Sendable {
    case boilerOrFurnace(BoilerOrFurnace)
    case electric(kilowatts: Int)
    case heatPump(capacity: HeatPumpCapacity)

    public static func boilerOrFurnace(afue: Percent, inputBTU: Int) -> Self {
      .boilerOrFurnace(.init(afue: afue, inputBTU: inputBTU))
    }

    public struct BoilerOrFurnace: Codable, Equatable, Sendable {
      public let afue: Percent
      public let inputBTU: Int

      public init(afue: Percent, inputBTU: Int) {
        self.afue = afue
        self.inputBTU = inputBTU
      }
    }
  }

  public enum Request {

    public struct Electric: Codable, Equatable, Sendable {
      public let kilowatts: Int
      public let heatingLoad: Int

      public init(kilowatts: Int, heatingLoad: Int) {
        self.kilowatts = kilowatts
        self.heatingLoad = heatingLoad
      }
    }

    public struct HeatPump: Codable, Equatable, Sendable {
      public let capacity: HeatPumpCapacity
      public let heatingLoad: Int
      public let projectElevation: Int
      public let outdoorDesignTemperature: Int

      public init(
        capacity: HeatPumpCapacity,
        heatingLoad: Int,
        projectElevation: Int = 0,
        outdoorDesignTemperature: Int
      ) {
        self.capacity = capacity
        self.heatingLoad = heatingLoad
        self.projectElevation = projectElevation
        self.outdoorDesignTemperature = outdoorDesignTemperature
      }
    }

    public struct FurnaceOrBoiler: Codable, Equatable, Sendable {

      public let inputBTU: Int
      public let afue: Percent
      public let heatingLoad: Int
      public let projectElevation: Int

      public init(
        inputBTU: Int,
        afue: Percent,
        heatingLoad: Int,
        projectElevation: Int = 0
      ) {
        self.inputBTU = inputBTU
        self.afue = afue
        self.heatingLoad = heatingLoad
        self.projectElevation = projectElevation
      }

    }
  }

  public enum Response {

    public struct GasOrBoiler: Codable, Equatable, Sendable {

      public let altitudeDerating: Percent?
      public let outputCapacity: Int
      public let finalCapacity: Int
      public let percentOfLoad: Percent
      public let sizingLimits: SizingLimit.Heating

      public init(
        altitudeDerating: Percent? = nil,
        outputCapacity: Int,
        finalCapacity: Int,
        percentOfLoad: Percent,
        sizingLimits: SizingLimit.Heating
      ) {
        self.altitudeDerating = altitudeDerating
        self.outputCapacity = outputCapacity
        self.finalCapacity = finalCapacity
        self.percentOfLoad = percentOfLoad
        self.sizingLimits = sizingLimits
      }
    }

    public struct Electric: Codable, Equatable, Sendable {

      public let requiredKW: Double
      public let percentOfLoad: Percent
      public let sizingLimits: SizingLimit.Heating

      public init(
        requiredKW: Double,
        percentOfLoad: Percent,
        sizingLimits: SizingLimit.Heating
      ) {
        self.requiredKW = requiredKW
        self.percentOfLoad = percentOfLoad
        self.sizingLimits = sizingLimits
      }
    }

    public struct HeatPump: Codable, Equatable, Sendable {

      public let deratings: Percent
      public let finalCapacity: HeatPumpCapacity
      public let capacityAtDesign: Double
      public let balancePointTemperature: Double
      public let requiredKW: Double

      public init(
        deratings: Percent,
        finalCapacity: HeatPumpCapacity,
        capacityAtDesign: Double,
        balancePointTemperature: Double,
        requiredKW: Double
      ) {
        self.deratings = deratings
        self.finalCapacity = finalCapacity
        self.capacityAtDesign = capacityAtDesign
        self.balancePointTemperature = balancePointTemperature
        self.requiredKW = requiredKW
      }
    }
  }
}

extension HeatingInterpolation {
  public struct Create: Codable, Equatable, Sendable {

    public let projectID: Project.ID
    public let interpolations: [Interpolation]

    public init(
      projectID: Project.ID,
      interpolations: [HeatingInterpolation.Interpolation]
    ) {
      self.projectID = projectID
      self.interpolations = interpolations
    }
  }

  public struct Update: Codable, Equatable, Sendable {

    public let interpolations: [Interpolation]

    public init(
      interpolations: [HeatingInterpolation.Interpolation]
    ) {
      self.interpolations = interpolations
    }
  }
}

// MARK: Validations
extension HeatingInterpolation.Interpolation: Validatable {
  public var body: some Validation<Self> {
    Validator.oneOf {
      Validator.case(\.boilerOrFurnace)
      Validator.case(\.electric, with: .greaterThan(0))
      Validator.case(\.heatPump)
    }
  }
}

extension HeatingInterpolation.Interpolation.BoilerOrFurnace: Validatable {
  public var body: some Validation<Self> {
    Validator.accumulating {
      Validator.validate(\.afue.rawValue) {
        Double.greaterThan(0)
        Double.lessThanOrEquals(100)
      }
      Validator.validate(\.inputBTU, with: .greaterThan(0))
    }
  }
}

extension HeatPumpCapacity: Validatable {
  public var body: some Validation<Self> {
    Validator.accumulating {
      Validator.validate(\.capacityAt47, with: .greaterThan(0))
      Validator.validate(\.capacityAt17, with: .greaterThan(0))
    }
  }
}
