import Foundation

extension RawRepresentable where RawValue == Double {
  public func string(digits: Int = 2) -> String {
    rawValue.string(digits: digits)
  }
}

extension RawRepresentable where RawValue == Int {
  public func string() -> String {
    rawValue.string()
  }
}

extension Double {
  public func string(digits: Int = 2) -> String {
    numberString(self, digits: digits)
  }
}

extension Int {
  public func string() -> String {
    numberString(Double(self), digits: 0)
  }
}

private func numberString(_ number: Double, digits: Int) -> String {
  let formatter = NumberFormatter()
  formatter.numberStyle = .decimal
  formatter.groupingSeparator = ","
  formatter.groupingSize = 3
  formatter.maximumFractionDigits = digits
  return formatter.string(for: number)!
}
