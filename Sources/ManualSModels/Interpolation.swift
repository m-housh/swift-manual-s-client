import Tagged

public enum Interpolation {

  public enum Cooling {
    public struct Response: Codable, Equatable, Sendable {

      public let interpolatedCapacity: CoolingCapacity
      public let excessLatent: Int
      public let finalCapacityAtyDesign: CoolingCapacity
      public let altitudeDeratings: CoolingDerating?
      public let capacityAsPercentOfLoad: CapacityAsPercentOfLoad

      public init(
        interpolatedCapacity: CoolingCapacity,
        excessLatent: Int,
        finalCapacityAtyDesign: CoolingCapacity,
        altitudeDeratings: CoolingDerating? = nil,
        capacityAsPercentOfLoad: CapacityAsPercentOfLoad
      ) {
        self.interpolatedCapacity = interpolatedCapacity
        self.excessLatent = excessLatent
        self.finalCapacityAtyDesign = finalCapacityAtyDesign
        self.altitudeDeratings = altitudeDeratings
        self.capacityAsPercentOfLoad = capacityAsPercentOfLoad
      }

      public struct CapacityAsPercentOfLoad: Codable, Equatable, Sendable {

        public let total: Percent
        public let sensible: Percent
        public let latent: Percent

        public init(total: Percent, sensible: Percent, latent: Percent) {
          self.total = total
          self.sensible = sensible
          self.latent = latent
        }
      }
    }

    public enum Request: Codable, Equatable, Sendable {
      case noInterpolation(NoInterpolation)
      case oneWayIndoor(Tagged<Tag.Indoor, OneWay>)
      case oneWayOutdoor(Tagged<Tag.Outdoor, OneWay>)
      case twoWay(TwoWay)

      public enum Tag {
        public enum Above {}
        public enum Below {}
        public enum Indoor {}
        public enum Outdoor {}
      }

      public struct NoInterpolation: Codable, Equatable, Sendable {

        public let capacity: ManufacturersCoolingCapacity
        public let adjustments: CoolingCapacityAdjustment?

        public init(
          capacity: ManufacturersCoolingCapacity,
          adjustments: CoolingCapacityAdjustment? = nil
        ) {
          self.capacity = capacity
          self.adjustments = adjustments
        }
      }

      public struct OneWayOutdoor: Codable, Equatable, Sendable {

        public let cfm: Int
        public let indoorTemperature: Int
        public let indoorWetBulbTemperature: Double
        public let aboveDesign: Capacity
        public let belowDesign: Capacity

        public init(
          cfm: Int,
          indoorTemperature: Int,
          indoorWetBulbTemperature: Double,
          aboveDesign: Interpolation.Cooling.Request.OneWayOutdoor.Capacity,
          belowDesign: Interpolation.Cooling.Request.OneWayOutdoor.Capacity
        ) {
          self.cfm = cfm
          self.indoorTemperature = indoorTemperature
          self.indoorWetBulbTemperature = indoorWetBulbTemperature
          self.aboveDesign = aboveDesign
          self.belowDesign = belowDesign
        }

        public struct Capacity: Codable, Equatable, Sendable {

          public let outdoorTemperature: Double
          public let capacity: CoolingCapacity

          public init(outdoorTemperature: Double, capacity: CoolingCapacity) {
            self.outdoorTemperature = outdoorTemperature
            self.capacity = capacity
          }
        }
      }

      public struct OneWay: Codable, Equatable, Sendable {

        public let aboveDesign: ManufacturersCoolingCapacity
        public let belowDesign: ManufacturersCoolingCapacity
        public let adjustments: CoolingCapacityAdjustment?

        public init(
          aboveDesign: ManufacturersCoolingCapacity,
          belowDesign: ManufacturersCoolingCapacity,
          adjustments: CoolingCapacityAdjustment? = nil
        ) {
          self.aboveDesign = aboveDesign
          self.belowDesign = belowDesign
          self.adjustments = adjustments
        }

      }

      public struct TwoWay: Codable, Equatable, Sendable {

        public let aboveDesign: Tagged<Tag.Above, Envelope>
        public let belowDesign: Tagged<Tag.Below, Envelope>
        public let adjustments: CoolingCapacityAdjustment?

        public init(
          aboveDesign: Tagged<
            Interpolation.Cooling.Request.Tag.Above,
            Interpolation.Cooling.Request.TwoWay.Envelope
          >,
          belowDesign: Tagged<
            Interpolation.Cooling.Request.Tag.Below,
            Interpolation.Cooling.Request.TwoWay.Envelope
          >,
          adjustments: CoolingCapacityAdjustment? = nil
        ) {
          self.aboveDesign = aboveDesign
          self.belowDesign = belowDesign
          self.adjustments = adjustments
        }

        public struct Envelope: Codable, Equatable, Sendable {

          public let aboveWetBulb: ManufacturersCoolingCapacity
          public let belowWetBulb: ManufacturersCoolingCapacity

          public init(
            aboveWetBulb: ManufacturersCoolingCapacity,
            belowWetBulb: ManufacturersCoolingCapacity
          ) {
            self.aboveWetBulb = aboveWetBulb
            self.belowWetBulb = belowWetBulb
          }
        }
      }

    }
  }

  // TODO: Do we need to return size limits??
  public enum Heating {

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
}
