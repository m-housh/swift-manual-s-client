import Tagged

public struct CoolingContainer: Codable, Equatable, Sendable {

  /// The total cooling capacity
  public let total: Double

  /// The sensible cooling capacity.
  public let sensible: Double

  public init(total: Double, sensible: Double) {
    self.total = total
    self.sensible = sensible
  }

}

public enum CoolingTag {
  public enum Capacity {}
  public enum Derating {}
}

public typealias CoolingCapacity = Tagged<CoolingTag.Capacity, CoolingContainer>
public typealias CoolingDerating = Tagged<CoolingTag.Derating, CoolingContainer>

extension CoolingCapacity {
  /// The latent cooling capacity.
  public var latent: Double {
    rawValue.total - rawValue.sensible
  }

  /// The sensible heat ratio.
  public var sensibleHeatRatio: Double {
    guard rawValue.total > 0, rawValue.sensible > 0 else { return 0 }
    return rawValue.sensible / rawValue.total
  }

}
