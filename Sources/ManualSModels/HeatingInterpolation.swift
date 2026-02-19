import Tagged

// TODO: Do we need to return size limits??
public enum HeatingInterpolation {

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
