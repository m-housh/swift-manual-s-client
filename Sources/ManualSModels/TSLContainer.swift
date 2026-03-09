import Tagged

/// A container that holds onto a total, sensible, and latent property for the
/// associated type.
///
public struct TSLContainer<N> {
  public let total: N
  public let sensible: N
  public let latent: N

  public init(
    total: N,
    sensible: N,
    latent: N
  ) {
    self.total = total
    self.sensible = sensible
    self.latent = latent
  }
}

public enum TSLTag {
  public enum CapacityAsPercentOfLoad {}
  public enum CoolingUndersizeLimit {}
  public enum FlaggedCapacity {}
}

extension TSLContainer: Codable where N: Codable {}
extension TSLContainer: Equatable where N: Equatable {}
extension TSLContainer: Sendable where N: Sendable {}

extension Tagged {
  public init<N>(total: N, sensible: N, latent: N) where RawValue == TSLContainer<N> {
    self.init(rawValue: .init(total: total, sensible: sensible, latent: latent))
  }
}
