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
  public enum CoolingLoad {}
  public enum Derating {}
}

public typealias CoolingCapacityAdjustment = Tagged<
  CoolingTag.AdjustmentMultiplier, CoolingContainer<Percent>
>
public typealias CoolingCapacity = Tagged<CoolingTag.Capacity, CoolingContainer<Double>>
public typealias CoolingDerating = Tagged<CoolingTag.Derating, CoolingContainer<Percent>>
public typealias CoolingLoad = Tagged<CoolingTag.CoolingLoad, CoolingContainer<Double>>

extension Tagged {
  public init<T>(total: T, sensible: T) where RawValue == CoolingContainer<T> {
    self.init(rawValue: .init(total: total, sensible: sensible))
  }
}

extension CoolingContainer where N: Numeric {
  /// The latent cooling capacity.
  public var latent: N {
    total - sensible
  }
}

public protocol Divisible: Numeric {
  static func / (lhs: Self, rhs: Self) -> Self
}

extension Double: Divisible {}

extension CoolingContainer where N: Divisible, N: Comparable {
  /// The sensible heat ratio.
  public var sensibleHeatRatio: N {
    guard total > 0, sensible > 0 else { return 0 }
    return sensible / total
  }

}
