public enum CoolingInterpolation {
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

  public struct Request: Codable, Equatable, Sendable {

    public let coolingLoad: CoolingLoad
    public let manufacturersAdjustments: CoolingCapacityAdjustment?
    public let outdoorDesignTemperature: Int
    public let projectElevation: Int
    public let interpolation: Self.Interpolation

    public init(
      coolingLoad: CoolingLoad,
      manufacturersAdjustments: CoolingCapacityAdjustment? = nil,
      outdoorDesignTemperature: Int,
      projectElevation: Int = 0,
      interpolation: CoolingInterpolation.Request.Interpolation
    ) {
      self.coolingLoad = coolingLoad
      self.manufacturersAdjustments = manufacturersAdjustments
      self.outdoorDesignTemperature = outdoorDesignTemperature
      self.projectElevation = projectElevation
      self.interpolation = interpolation
    }

    public enum Interpolation: Codable, Equatable, Sendable {
      case noInterpolation(CoolingCapacity)
      case oneWayIndoor(OneWayIndoor)
      case oneWayOutdoor(OneWayOutdoor)
      case twoWay(TwoWay)

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
            aboveWetBulb: CoolingInterpolation.Request.Interpolation.OneWayIndoor.Envelope,
            belowWetBulb: CoolingInterpolation.Request.Interpolation.OneWayIndoor.Envelope
          ) {
            self.outdoorTemperature = outdoorTemperature
            self.aboveWetBulb = aboveWetBulb
            self.belowWetBulb = belowWetBulb
          }
        }
      }
    }
  }

}
