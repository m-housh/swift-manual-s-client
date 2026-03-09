@preconcurrency import URLRouting

public struct Percent: Codable, Equatable, Sendable, RawRepresentable {
  public var rawValue: Double

  public var decimal: Double {
    rawValue / 100
  }

  public init(_ value: Double) {
    self.rawValue = value
  }

  public init(rawValue: Double) {
    self.init(rawValue)
  }

  public init(decimal: Double) {
    self.init(decimal * 100)
  }
}

extension Percent: Numeric {
  public init?<T>(exactly source: T) where T: BinaryInteger {
    self.rawValue = Double(source)
  }

  public typealias Magnitude = Double

  public var magnitude: Magnitude {
    rawValue.magnitude
  }

  public static func * (lhs: Percent, rhs: Percent) -> Percent {
    .init(lhs.rawValue * rhs.rawValue)
  }

  public static func *= (lhs: inout Percent, rhs: Percent) {
    lhs = .init((lhs * rhs).rawValue)
  }

  public static func + (lhs: Percent, rhs: Percent) -> Percent {
    .init(lhs.rawValue + rhs.rawValue)
  }

  public static func - (lhs: Percent, rhs: Percent) -> Percent {
    .init(lhs.rawValue - rhs.rawValue)
  }

  public typealias IntegerLiteralType = Int

  public init(integerLiteral value: IntegerLiteralType) {
    self.init(Double(value))
  }

}

extension Percent: ExpressibleByFloatLiteral {
  public typealias FloatLiteralType = Double

  public init(floatLiteral value: FloatLiteralType) {
    self.init(value)
  }
}

extension Percent: ExpressibleByIntegerLiteral {}

extension Percent {
  public static func parser() -> AnyParserPrinter<Substring.UTF8View, Self> {
    Double.parser().map(.memberwise(Self.init(rawValue:)))
      .eraseToAnyParserPrinter()
  }
}

extension Percent: Comparable {
  public static func < (lhs: Percent, rhs: Percent) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
}
