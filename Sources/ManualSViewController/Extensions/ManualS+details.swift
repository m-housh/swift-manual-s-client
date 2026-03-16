import ManualSClient
import ManualSModels

extension ManualSClient {

  func coolingInterpolation(
    projectDetails: Project.Details
  ) async -> CoolingInterpolation.Response? {
    guard let interpolation = projectDetails.coolingInterpolation,
      let houseLoad = projectDetails.houseLoad,
      let designInfo = projectDetails.designInfo,
      let systemType = projectDetails.systemType,
      let coolingSystemType = systemType.cooling
    else {
      return nil
    }

    return try? await coolingInterpolation(
      .init(
        coolingLoad: houseLoad.cooling,
        manufacturersAdjustments: interpolation.manufacturersAdjustments,
        outdoorDesignTemperature: designInfo.summerOutdoorTemperature,
        projectElevation: designInfo.elevation,
        interpolation: interpolation.interpolation,
        systemType: coolingSystemType
      )
    )
  }

  func heatingInterpolations(
    projectDetails: Project.Details
  ) async throws -> [(HeatingInterpolation, HeatingInterpolation.Response)] {

    guard let heatingLoad = projectDetails.houseLoad?.heating,
      let designInfo = projectDetails.designInfo
    else {
      return []
    }

    var retVal = [(HeatingInterpolation, HeatingInterpolation.Response)]()
    for interpolation in projectDetails.heatingInterpolations {
      switch interpolation.interpolation {
      case .heatPump(let capacity):
        let response = try await heatPumpHeatingInterpolation(
          .init(
            capacity: capacity,
            heatingLoad: Int(heatingLoad),
            projectElevation: designInfo.elevation,
            outdoorDesignTemperature: designInfo.winterOutdoorTemperature
          )
        )
        retVal.append((interpolation, .heatPump(response)))
      default:
        break
      }
    }
    return retVal
  }
}
