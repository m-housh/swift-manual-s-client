import Tagged

public struct CoolingContainer<N> {

  /// The total cooling capacity
  public let total: N

  /// The sensible cooling capacity.
  public let sensible: N

  public init(total: N, sensible: N) {
    self.total = total
    self.sensible = sensible
  }

}
extension CoolingContainer: Codable where N: Codable {}
extension CoolingContainer: Equatable where N: Equatable {}
extension CoolingContainer: Sendable where N: Sendable {}

public enum CoolingTag {
  public enum AdjustmentMultiplier {}
  public enum Capacity {}
  public enum Derating {}
}

public typealias CoolingCapacityAdjustment = Tagged<
  CoolingTag.AdjustmentMultiplier, CoolingContainer<Percent>
>
public typealias CoolingCapacity = Tagged<CoolingTag.Capacity, CoolingContainer<Double>>
public typealias CoolingDerating = Tagged<CoolingTag.Derating, CoolingContainer<Percent>>

extension CoolingCapacity {

  public init(total: Double, sensible: Double) {
    self.init(rawValue: .init(total: total, sensible: sensible))
  }

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
