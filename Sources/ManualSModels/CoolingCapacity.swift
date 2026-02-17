public struct CoolingCapcity: Codable, Equatable, Sendable {
  /// The total cooling capacity
  public let total: Double

  /// The sensible cooling capacity.
  public let sensible: Double

  /// The latent cooling capacity.
  public var latent: Double {
    total - sensible
  }

  /// The sensible heat ratio.
  public var sensibleHeatRatio: Double {
    guard total > 0, sensible > 0 else { return 0 }
    return sensible / total
  }

  public init(total: Double, sensible: Double) {
    self.total = total
    self.sensible = sensible
  }
}
