import CasePathsCore
import FluentKit
import ManualSModels
import Tagged
@preconcurrency import URLRouting

import struct SharedModels.Project
import protocol SharedModels.Routeable
import enum SharedModels.SharedRoute

public enum ManualSRoute: Equatable, Sendable, Routeable {
  case index
  case projectDetail(Project.ID, ProjectDetail)
  case shared(SharedRoute)

  public static let router = OneOf {
    Route(.case(Self.index)) {
      Method.get
    }
    Route(.case(Self.projectDetail)) {
      Path {
        "projects"
        Project.ID.parser()
      }
      ProjectDetail.router
    }
    Route(.case(Self.shared)) {
      SharedRoute.router
    }
  }

  public enum ProjectDetail: Equatable, Sendable, Routeable {
    case index
    case designInfo(DesignInfo.ViewRoute)
    case houseLoads(HouseLoad.ViewRoute)
    case interpolations(Interpolations)
    case proposedEquipment(ProposedEquipment.ViewRoute)
    case systemTypes(SystemType.ViewRoute)

    public static let router = OneOf {
      Route(.case(Self.index)) {
        Method.get
      }
      Route(.case(Self.designInfo)) {
        DesignInfo.ViewRoute.router
      }
      Route(.case(Self.houseLoads)) {
        HouseLoad.ViewRoute.router
      }
      Route(.case(Self.interpolations)) {
        Interpolations.router
      }
      Route(.case(Self.proposedEquipment)) {
        ProposedEquipment.ViewRoute.router
      }
      Route(.case(Self.systemTypes)) {
        SystemType.ViewRoute.router
      }
    }

    public enum Interpolations: Equatable, Sendable, Routeable {
      case cooling(CoolingInterpolation.ViewRoute)
      case heating(HeatingInterpolation.ViewRoute)

      static let path = "interpolations"

      public static let router = OneOf {
        Route(.case(Self.cooling)) {
          Path { path }
          CoolingInterpolation.ViewRoute.router
        }
        Route(.case(Self.heating)) {
          Path { path }
          HeatingInterpolation.ViewRoute.router
        }
      }
    }
  }

}

extension Tagged where RawValue == UUID {
  public static func parser() -> AnyParserPrinter<Substring.UTF8View, Self> {
    UUID.parser()
      .map(.representing(Self.self))
      .eraseToAnyParserPrinter()
  }
}
