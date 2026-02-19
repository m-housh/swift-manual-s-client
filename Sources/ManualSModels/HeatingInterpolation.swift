import Tagged

// TODO: Do we need to return size limits??
public enum HeatingInterpolation {

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
