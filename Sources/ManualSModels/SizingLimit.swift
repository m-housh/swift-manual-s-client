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
    public let total: Int
    public let latent: Int

    public init(total: Int, latent: Int) {
      self.total = total
      self.latent = latent
    }
  }

  public struct CoolingUndersizeLimit: Codable, Equatable, Sendable {
    public let total: Int
    public let sensible: Int
    public let latent: Int

    public init(
      total: Int,
      sensible: Int,
      latent: Int
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
