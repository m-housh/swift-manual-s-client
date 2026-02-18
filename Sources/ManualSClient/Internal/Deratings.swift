import Foundation
import ManualSModels

extension CoolingDerating {

  init(elevation: Double) async {
    self.init(
      rawValue: .init(
        total: .init(decimal: totalWetDerating(elevation: elevation)),
        sensible: .init(decimal: sensibleWetDerating(elevation: elevation))
      )
    )
  }
}

extension SystemType.Heating {

  func derating(elevation: Double) async -> Double {
    switch self {
    case .boiler, .furnace:
      return bolierOrFurnaceDerating(elevation: elevation)
    case .heatPump:
      return totalDryDerating(elevation: elevation)
    case .electric:
      return 1
    }
  }
}

private func totalWetDerating(elevation: Double) -> Double {
  guard elevation > 0 else { return 1 }

  if (0..<1000).contains(elevation) { return 1 }
  if (1000..<2000).contains(elevation) { return 0.99 }
  if (2000..<3000).contains(elevation) { return 0.98 }
  if (3000..<4000).contains(elevation) { return 0.98 }
  if (4000..<5000).contains(elevation) { return 0.97 }
  if (5000..<6000).contains(elevation) { return 0.96 }
  if (6000..<7000).contains(elevation) { return 0.95 }
  if (7000..<8000).contains(elevation) { return 0.94 }
  if (8000..<9000).contains(elevation) { return 0.94 }
  if (9000..<10000).contains(elevation) { return 0.93 }
  if (10000..<11000).contains(elevation) { return 0.92 }
  if (11000..<12000).contains(elevation) { return 0.91 }
  // greater than 12,000 feet in elevation.
  return 0.9
}

private func sensibleWetDerating(elevation: Double) -> Double {
  guard elevation > 0 else { return 1 }

  if (0..<1000).contains(elevation) { return 1 }
  if (1000..<2000).contains(elevation) { return 0.97 }
  if (2000..<3000).contains(elevation) { return 0.94 }
  if (3000..<4000).contains(elevation) { return 0.91 }
  if (4000..<5000).contains(elevation) { return 0.88 }
  if (5000..<6000).contains(elevation) { return 0.85 }
  if (6000..<7000).contains(elevation) { return 0.82 }
  if (7000..<8000).contains(elevation) { return 0.8 }
  if (8000..<9000).contains(elevation) { return 0.77 }
  if (9000..<10000).contains(elevation) { return 0.74 }
  if (10000..<11000).contains(elevation) { return 0.71 }
  if (11000..<12000).contains(elevation) { return 0.68 }
  // greater than 12,000 feet in elevation.
  return 0.65
}

private func bolierOrFurnaceDerating(elevation: Double) -> Double {
  guard elevation > 0 else { return 1 }

  if (0..<1000).contains(elevation) { return 1 }
  if (1000..<2000).contains(elevation) { return 0.96 }
  if (2000..<3000).contains(elevation) { return 0.92 }
  if (3000..<4000).contains(elevation) { return 0.88 }
  if (4000..<5000).contains(elevation) { return 0.84 }
  if (5000..<6000).contains(elevation) { return 0.8 }
  if (6000..<7000).contains(elevation) { return 0.76 }
  if (7000..<8000).contains(elevation) { return 0.72 }
  if (8000..<9000).contains(elevation) { return 0.68 }
  if (9000..<10000).contains(elevation) { return 0.64 }
  if (10000..<11000).contains(elevation) { return 0.6 }
  if (11000..<12000).contains(elevation) { return 0.56 }
  // greater than 12,000 feet in elevation.
  return 0.52
}

private func totalDryDerating(elevation: Double) -> Double {
  guard elevation > 0 else { return 1 }

  if (0..<1000).contains(elevation) { return 1 }
  if (1000..<2000).contains(elevation) { return 0.98 }
  if (2000..<3000).contains(elevation) { return 0.97 }
  if (3000..<4000).contains(elevation) { return 0.95 }
  if (4000..<5000).contains(elevation) { return 0.94 }
  if (5000..<6000).contains(elevation) { return 0.92 }
  if (6000..<7000).contains(elevation) { return 0.9 }
  if (7000..<8000).contains(elevation) { return 0.89 }
  if (8000..<9000).contains(elevation) { return 0.87 }
  if (9000..<10000).contains(elevation) { return 0.86 }
  if (10000..<11000).contains(elevation) { return 0.84 }
  if (11000..<12000).contains(elevation) { return 0.82 }
  // greater than 12,000 feet in elevation.
  return 0.81
}
