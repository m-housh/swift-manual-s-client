import CasePathsCore
import FluentKit
import ManualSModels
import SharedModels
import Tagged
@preconcurrency import URLRouting

public enum ManualSRoute: Sendable, Routeable {
  case index
  case designInfo(DesignInfo.ViewRoute)
  case houseLoad(HouseLoad.ViewRoute)
  case proposedEquipment(ProposedEquipment.ViewRoute)
  case shared(SharedRoute)
  case systemType(SystemType.ViewRoute)

  public static let router = OneOf {
    Route(.case(Self.index)) {
      Method.get
    }
    Route(.case(Self.designInfo)) {
      DesignInfo.ViewRoute.router
    }
    Route(.case(Self.houseLoad)) {
      HouseLoad.ViewRoute.router
    }
    Route(.case(Self.proposedEquipment)) {
      ProposedEquipment.ViewRoute.router
    }
    Route(.case(Self.shared)) {
      SharedRoute.router
    }
    Route(.case(Self.systemType)) {
      SystemType.ViewRoute.router
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
