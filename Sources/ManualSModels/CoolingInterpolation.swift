import Tagged

public enum CoolingInterpolation {
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
