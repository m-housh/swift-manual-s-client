import CasePathsCore
import FluentKit
import ManualSModels
import SharedModels
import Tagged
@preconcurrency import URLRouting

public enum ManualSRoute: Sendable, Routeable {
  case index
  case designInfo(DesignInfo.ViewRoute)
  case houseLoads(HouseLoad.ViewRoute)
  case interpolations(Interpolations)
  case proposedEquipment(ProposedEquipment.ViewRoute)
  case shared(SharedRoute)
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
    Route(.case(Self.shared)) {
      SharedRoute.router
    }
    Route(.case(Self.systemTypes)) {
      SystemType.ViewRoute.router
    }
  }

  public enum Interpolations: Sendable, Routeable {
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

extension Tagged where RawValue == UUID {
  public static func parser() -> AnyParserPrinter<Substring.UTF8View, Self> {
    UUID.parser()
      .map(.representing(Self.self))
      .eraseToAnyParserPrinter()
  }
}
