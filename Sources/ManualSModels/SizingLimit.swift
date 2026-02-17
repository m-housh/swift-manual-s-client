public struct SizingLimit: Codable, Equatable, Sendable {

  public let oversizing: Oversizing
  public let undersizing: UnderSizing

  public enum Oversizing: Codable, Equatable, Sendable {

    case cooling(Cooling)
    case heating(SizingLimit.Heating)

    public struct Cooling: Codable, Equatable, Sendable {
      public let total: Int
      public let latent: Int

      public init(total: Int, latent: Int = 150) {
        self.total = total
        self.latent = latent
      }
    }
  }

  public enum UnderSizing: Codable, Equatable, Sendable {

    case cooling(Cooling)
    case heating(SizingLimit.Heating)

    public struct Cooling: Codable, Equatable, Sendable {
      public let total: Int
      public let sensible: Int
      public let latent: Int

      public init(
        total: Int = 90,
        sensible: Int = 90,
        latent: Int = 90
      ) {
        self.total = total
        self.sensible = sensible
        self.latent = latent
      }
    }
  }

  public struct Heating: Codable, Equatable, Sendable {
    public let type: SystemType.Heating
    public let value: Int

    public init(
      type: SystemType.Heating,
      value: Int = 90
    ) {
      self.type = type
      self.value = value
    }

  }
}
