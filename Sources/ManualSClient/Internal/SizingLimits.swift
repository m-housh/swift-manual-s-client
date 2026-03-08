import Foundation
import ManualSModels

extension ManualSClient.CoolingSizeLimitRequest {

  func respond() async throws -> SizingLimit.Cooling {

    let oversizingLimit: Double

    switch self {
    case .mildWinterOrLatentLoad(let compressor):
      switch compressor {
      case .singleSpeed:
        oversizingLimit = 115
      case .multiSpeed:
        oversizingLimit = 120
      case .variableSpeed:
        oversizingLimit = 130
      }
    case .coldWinterOrNoLatentLoad(let totalCoolingLoad):
      oversizingLimit = round(((totalCoolingLoad + 15000) / totalCoolingLoad) * 100)
    }

    return .init(
      oversizing: .init(total: .init(oversizingLimit), latent: 150),
      undersizing: .init(total: 90, sensible: 90, latent: 90)
    )

  }

}

extension SystemType.Heating {

  var sizingLimit: SizingLimit.Heating {
    .init(oversizing: 140, undersizing: 90)
  }
}
