public struct SizingLimit: Codable, Equatable, Sendable {

  public typealias Cooling = Container<CoolingOversizeLimit, CoolingUndersizeLimit>
  public typealias Heating = Container<Int, Int>

  public struct Container<Over, Under> {

    public let oversizing: Over
    public let undersizing: Under

    public init(oversizing: Over, undersizing: Under) {
      self.oversizing = oversizing
      self.undersizing = undersizing
    }
  }

  public struct CoolingOversizeLimit: Codable, Equatable, Sendable {
    public let total: Percent
    public let latent: Percent

    public init(total: Percent, latent: Percent) {
      self.total = total
      self.latent = latent
    }
  }

  public struct CoolingUndersizeLimit: Codable, Equatable, Sendable {
    public let total: Percent
    public let sensible: Percent
    public let latent: Percent

    public init(
      total: Percent,
      sensible: Percent,
      latent: Percent
    ) {
      self.total = total
      self.sensible = sensible
      self.latent = latent
    }
  }
}

extension SizingLimit.Container: Codable where Over: Codable, Under: Codable {}
extension SizingLimit.Container: Equatable where Over: Equatable, Under: Equatable {}
extension SizingLimit.Container: Sendable where Over: Sendable, Under: Sendable {}

#if DEBUG
  extension SizingLimit.Cooling {
    public static let mock = Self(
      oversizing: .init(total: 115, latent: 150),
      undersizing: .init(total: 90, sensible: 90, latent: 90)
    )
  }
#endif
