import Foundation

func calculateRequiredKW(heatLoss: Double, capacityAtDesign: Double) async -> Double {
  (heatLoss - capacityAtDesign) / 3413
}
