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
          let details = try await fetchDetails(for: projectID)

          guard let projectDetails = details.details else {
            throw NotFoundError()
          }

          let user = try auth.currentUser()
          return ProjectDetailsView(
            user: user,
            details: projectDetails,
            coolingInterpolationResponse: details.coolingInterpolationResponse,
            heatingInterpolations: details.heatingInterpolations ?? []
          )
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
        return .projectDetailsUpdate(projectID) {
          await ResultView {
            let designInfo = try await database.designInfo.create(form)
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .designInfo(designInfo)
            )
          }
        }
      case .update(let designInfoID, let updates):
        return .projectDetailsUpdate(projectID) {
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
        return .projectDetailsUpdate(projectID) {
          await ResultView {
            let systemTypes = try await database.systemTypes.create(form)
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .coolingSystemType(systemTypes)
            )
          }
        }
      case .update(let id, let updates):
        return .projectDetailsUpdate(projectID) {
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
        return .projectDetailsUpdate(projectID) {
          await ResultView {
            let proposedEquipment = try await database.proposedEquipment.create(form.toCreate())
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .proposedEquipment(proposedEquipment)
            )
          }
        }
      case .update(let id, let updates):
        return .projectDetailsUpdate(projectID) {
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
        return .projectDetailsUpdate(projectID) {
          await ResultView {
            let houseLoads = try await database.houseLoads.create(form)
            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .houseLoad(houseLoads)
            )
          }
        }
      case .update(let id, let updates):
        return .projectDetailsUpdate(projectID) {
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
      case .result(_):
        return .view {
          // return div { "Results..." }
          await makeCoolingInterpolationResultView(projectID: projectID)
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

            let details = try await database.projects.fetchDetails(projectID)
            var responses = [(HeatingInterpolation, HeatingInterpolation.Response)]()
            if let details {
              responses = try await manualS.heatingInterpolations(projectDetails: details)
            }

            // let interpolations = try await database.heatingInterpolations.fetch(projectID)
            // guard let designInfo = try await database.designInfo.fetch(projectID),
            //   let houseLoad = try await database.houseLoads.fetch(projectID)
            // else {
            //   // return HeatingInterpolationsView(projectID: projectID, interpolations: [])
            //   throw NotFoundError()
            // }
            //
            // let responses = try await manualS.heatingInterpolations(
            //   interpolations,
            //   designInfo: designInfo,
            //   heatingLoad: Int(houseLoad.heating)
            // )

            return ProjectDetailsView.Section(
              projectID: projectID,
              section: .heatingInterpolation(responses)
            )
          }
        }
      case .submit(let form):
        return .view {

          let _ = try await database.heatingInterpolations.create(form)
          let details = try await database.projects.fetchDetails(projectID)
          var responses = [(HeatingInterpolation, HeatingInterpolation.Response)]()
          if let details {
            responses = try await manualS.heatingInterpolations(projectDetails: details)
          }

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

private func makeCoolingInterpolationResponseTable(
  projectDetails: Project.Details
) async -> some HTML & Sendable {
  @Dependency(\.manualS) var manualS
  return await ResultView {
    let response = await manualS.coolingInterpolation(projectDetails: projectDetails)
    return CoolingInterpolationResponseTable(response: response)
  }
}

private func makeCoolingInterpolationResultView(
  projectID: ManualSModels.Project.ID
) async -> some HTML
  & Sendable
{
  @Dependency(\.database) var database
  return await ResultView {
    guard let details = try await database.projects.fetchDetails(projectID) else {
      throw NotFoundError()
    }
    return await makeCoolingInterpolationResponseTable(projectDetails: details)
  }
}

struct ProjectDetails: Sendable {

  let details: Project.Details?
  let coolingInterpolationResponse: CoolingInterpolation.Response?
  let heatingInterpolations: [(HeatingInterpolation, HeatingInterpolation.Response)]?

  internal init(
    details: Project.Details? = nil,
    coolingInterpolationResponse: CoolingInterpolation.Response? = nil,
    heatingInterpolations: [(HeatingInterpolation, HeatingInterpolation.Response)]? = nil
  ) {
    self.details = details
    self.coolingInterpolationResponse = coolingInterpolationResponse
    self.heatingInterpolations = heatingInterpolations
  }
}

private func fetchDetails(for projectID: Project.ID) async throws -> ProjectDetails {
  @Dependency(\.database) var database
  @Dependency(\.manualS) var manualS

  guard let details = try await database.projects.fetchDetails(projectID)
  else { return .init() }

  return .init(
    details: details,
    coolingInterpolationResponse: await manualS.coolingInterpolation(projectDetails: details),
    heatingInterpolations: try await manualS.heatingInterpolations(projectDetails: details)
  )
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

extension ViewResponse {
  fileprivate static func projectDetailsUpdate<V: HTML>(
    _ projectID: Project.ID,
    @HTMLBuilder content: @escaping @Sendable () async -> V
  ) -> Self where V: Sendable {
    self.view {
      await ResultView {
        @Dependency(\.database) var database
        @Dependency(\.manualS) var manualS
        return (
          try await database.projects.fetchDetails(projectID),
          await content()
        )
      } onSuccess: { (projectDetails, content) in
        Group {
          content
          if let details = projectDetails {
            ProjectDetailsView.Section(
              projectID: projectID,
              section: .coolingInterpolation(details.coolingInterpolation, details.designInfo)
            )
            .attributes(.hx.swapOOB(true))

            // FIX: Heating Interpolations
          }
        }
      }
    }
  }
}
