import AuthClient
import Dependencies
import Elementary
import ManualSClient
import ManualSDatabase
import ManualSModels
import ManualSRouter
import SharedDatabase
import SharedMiddleware
import SharedModels
import SharedStyleguide
import SharedViews
import Vapor

// FIX: Need to redirect to projects / home page after signup flow is complete
public struct ManualSViewController: ViewController {

  public init() {}

  let sharedController = SharedViewController(
    auth: AuthViewController(),
    projects: ProjectViewController { project in
      // FIX: What do we do with project view controller, until it's removed from
      //      shared setup.
      // @Dependency(\.auth) var auth
      // return try ProjectDetailsView(user: auth.currentUser(), project: project)
    },
    users: UserViewController()
  )

  public func view(
    for route: ManualSRoute,
    on request: Request
  ) async throws -> ViewResponse {

    @Dependency(\.database) var database

    switch route {
    case .index:
      return .redirect(to: ManualSRoute.router.path(for: .shared(.project(.index))))

    case .projectDetail(let projectID, let route):
      return try await route.view(projectID: projectID)

    case .shared(let route):
      return try await sharedController.view(for: route, on: request)
    }
  }
}

extension ManualSRoute.ProjectDetail {

  func view(projectID: ManualSModels.Project.ID) async throws -> ViewResponse {
    @Dependency(\.auth) var auth
    @Dependency(\.database) var database
    @Dependency(\.manualS) var manualS

    switch self {
    case .index:
      return .view {
        await ResultView {
          guard let project = try await database.projects.get(projectID) else {
            throw NotFoundError()
          }
          let user = try auth.currentUser()
          return ProjectDetailsView(user: user, project: project)
        }
      }
    case .designInfo(let route):
      switch route {
      case .index:
        return .view {
          await ResultView {
            let designInfo = try await database.designInfo.fetch(projectID)
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .designInfo(designInfo)
            )
          }
        }
      case .submit(let form):
        return .view {
          await ResultView {
            let designInfo = try await database.designInfo.create(form)
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .designInfo(designInfo)
            )
          }
        }
      case .update(let designInfoID, let updates):
        return .view {
          await ResultView {
            let designInfo = try await database.designInfo.update(designInfoID, updates)
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .designInfo(designInfo)
            )
          }
        }
      }

    case .systemTypes(let route):
      switch route {
      case .index:
        return .view {
          await ResultView {
            let systemTypes = try await database.systemTypes.fetch(projectID)
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .coolingSystemType(systemTypes)
            )
          }
        }
      case .submit(let form):
        return .view {
          await ResultView {
            let systemTypes = try await database.systemTypes.create(form)
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .coolingSystemType(systemTypes)
            )
          }
        }
      case .update(let id, let updates):
        return .view {
          await ResultView {
            let systemTypes = try await database.systemTypes.update(id, updates)
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .coolingSystemType(systemTypes)
            )
          }
        }
      }

    case .proposedEquipment(let route):
      switch route {
      case .index:
        return .view {
          await ResultView {
            let proposedEquipment = try await database.proposedEquipment.fetch(projectID)
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .proposedEquipment(proposedEquipment)
            )
          }
        }
      case .equipmentRow:
        return .view {
          ProposedEquipmentForm.EquipmentTable.Row(equipment: nil)
        }
      case .submit(let form):
        return .view {
          await ResultView {
            let proposedEquipment = try await database.proposedEquipment.create(form.toCreate())
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .proposedEquipment(proposedEquipment)
            )
          }
        }
      case .update(let id, let updates):
        return .view {
          await ResultView {
            let proposedEquipment = try await database.proposedEquipment.update(
              id, updates.toUpdate())
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .proposedEquipment(proposedEquipment)
            )
          }
        }
      }

    case .houseLoads(let route):
      switch route {
      case .index:
        return .view {
          await ResultView {
            let houseLoads = try await database.houseLoads.fetch(projectID)
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .houseLoad(houseLoads)
            )
          }
        }
      case .submit(let form):
        return .view {
          await ResultView {
            let houseLoads = try await database.houseLoads.create(form)
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .houseLoad(houseLoads)
            )
          }
        }
      case .update(let id, let updates):
        return .view {
          await ResultView {
            let houseLoads = try await database.houseLoads.update(id, updates)
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .houseLoad(houseLoads)
            )
          }
        }
      }

    case .interpolations(.cooling(let route)):
      switch route {
      case .index:
        return .view {
          await ResultView {
            let interpolation = try await database.coolingInterpolations.fetch(projectID)
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .coolingInterpolation(interpolation)
            )
          }
        }
      case .result(let id):
        return .view {
          // return div { "Results..." }
          await makeCoolingInterpolationResultView(id: id, projectID: projectID)
        }
      case .submit(let form):
        return .view {
          await ResultView {
            let interpolation = try await database.coolingInterpolations.create(form.toCreate())
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .coolingInterpolation(interpolation)
            )
          }
        }
      case .update(let id, let updates):
        return .view {
          await ResultView {
            let interpolation = try await database.coolingInterpolations.update(
              id, updates.toUpdate())
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .coolingInterpolation(interpolation)
            )
          }
        }
      }

    case .interpolations(.heating(let route)):
      switch route {
      case .index:
        return .view {
          await ResultView {
            let interpolations = try await database.heatingInterpolations.fetch(projectID)
            guard let designInfo = try await database.designInfo.fetch(projectID),
              let houseLoad = try await database.houseLoads.fetch(projectID)
            else {
              // return HeatingInterpolationsView(projectID: projectID, interpolations: [])
              throw NotFoundError()
            }

            let responses = try await manualS.heatingInterpolations(
              interpolations,
              designInfo: designInfo,
              heatingLoad: Int(houseLoad.heating)
            )

            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .heatingInterpolation(responses)
            )
          }
        }
      case .submit(let form):
        return .view {

          let _ = try await database.heatingInterpolations.create(form)
          // FIX: Make a helper or something to not repeat this code.
          let interpolations = try await database.heatingInterpolations.fetch(projectID)
          guard let designInfo = try await database.designInfo.fetch(projectID),
            let houseLoad = try await database.houseLoads.fetch(projectID)
          else {
            // return HeatingInterpolationsView(projectID: projectID, interpolations: [])
            throw NotFoundError()
          }

          let responses = try await manualS.heatingInterpolations(
            interpolations,
            designInfo: designInfo,
            heatingLoad: Int(houseLoad.heating)
          )

          return ProjectDetailsView.Section(
            projectID: projectID,
            section: .heatingInterpolation(responses)
          )
        }
      case .update(_, _):
        fatalError()
      }
    }
  }

}

private func makeCoolingInterpolationResultView(
  id: CoolingInterpolation.ID,
  projectID: ManualSModels.Project.ID
) async -> some HTML
  & Sendable
{
  @Dependency(\.database) var database
  @Dependency(\.manualS) var manualS

  return await ResultView {
    guard let interpolation = try await database.coolingInterpolations.get(id),
      let houseLoad = try await database.houseLoads.fetch(projectID),
      let designInfo = try await database.designInfo.fetch(projectID),
      let systemType = try await database.systemTypes.fetch(projectID),
      let coolingSystemType = systemType.cooling
    else {
      throw NotFoundError()
    }
    let response = try await manualS.coolingInterpolation(
      .init(
        coolingLoad: houseLoad.cooling,
        manufacturersAdjustments: interpolation.manufacturersAdjustments,
        outdoorDesignTemperature: designInfo.summerOutdoorTemperature,
        projectElevation: designInfo.elevation,
        interpolation: interpolation.interpolation,
        systemType: coolingSystemType
      )
    )
    return CoolingInterpolationResponseTable(response: response)
  }
}

extension SystemType.Cooling {
  fileprivate func coolingSizingLimitRequest(
    totalCoolingLoad: Double
  ) -> ManualSClient.CoolingSizeLimitRequest {
    switch climate {
    case .coldWinterOrNoLatentLoad:
      return .coldWinterOrNoLatentLoad(totalCoolingLoad: totalCoolingLoad)
    case .mildWinterOrLatentLoad:
      return .mildWinterOrLatentLoad(compressor: compressor)
    }
  }
}

extension ManualSClient {
  fileprivate func heatingInterpolations(
    _ interpolations: [HeatingInterpolation],
    designInfo: DesignInfo,
    heatingLoad: Int
  ) async throws -> [(HeatingInterpolation, HeatingInterpolation.Response)] {
    var retVal = [(HeatingInterpolation, HeatingInterpolation.Response)]()
    for interpolation in interpolations {
      switch interpolation.interpolation {
      case .heatPump(let capacity):
        let response = try await heatPumpHeatingInterpolation(
          .init(
            capacity: capacity,
            heatingLoad: heatingLoad,
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
