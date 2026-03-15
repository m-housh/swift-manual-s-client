import CasePathsCore
import FoundationEssentials
import ManualSModels
import Tagged
@preconcurrency import URLRouting

import protocol SharedModels.Routeable

extension HeatingInterpolation {
  public enum ViewRoute: Equatable, Sendable, Routeable {
    case index
    case submit(HeatingInterpolation.Create)
    case update(HeatingInterpolation.ID, HeatingInterpolation.Update)

    static let path = "heating"

    public static let router = OneOf {
      Route(.case(Self.index)) {
        Path { path }
        Method.get
      }
      Route(.case(Self.submit)) {
        Path { path }
        Method.post
        Body {
          HeatingInterpolation.Create.parser
        }
      }
      Route(.case(Self.update)) {
        Path {
          path
          HeatingInterpolation.ID.parser()
        }
        Method.post
        Body {
          HeatingInterpolation.Update.parser
        }
      }
    }
  }
}

// FIX: Heat Pump form should also include kilowatt field
extension HeatingInterpolation.Create {
  static let parser = FormData {
    Field("projectID") { Project.ID.parser() }
    OneOf {
      ParsePrint(.memberwise(HeatingInterpolation.Interpolation.BoilerOrFurnace.init)) {
        Field("afue") { Percent.parser() }
        Field("inputBTU") { Int.parser() }
      }
      .map(.case(HeatingInterpolation.Interpolation.boilerOrFurnace))

      ParsePrint(.case(HeatingInterpolation.Interpolation.electric)) {
        Field("kilowatts") { Int.parser() }
      }

      ParsePrint(.memberwise(HeatPumpCapacity.init)) {
        Field("capacityAt47") { Double.parser() }
        Field("capacityAt17") { Double.parser() }
      }
      .map(.case(HeatingInterpolation.Interpolation.heatPump))
    }
  }
  .map(.memberwise(HeatingInterpolation.Create.init(projectID:interpolation:)))
}

extension HeatingInterpolation.Update {
  static let parser = FormData {
    OneOf {
      ParsePrint(.memberwise(HeatingInterpolation.Interpolation.BoilerOrFurnace.init)) {
        Field("afue") { Percent.parser() }
        Field("inputBTU") { Int.parser() }
      }
      .map(.case(HeatingInterpolation.Interpolation.boilerOrFurnace))

      ParsePrint(.case(HeatingInterpolation.Interpolation.electric)) {
        Field("kilowatts") { Int.parser() }
      }

      ParsePrint(.memberwise(HeatPumpCapacity.init)) {
        Field("capacityAt47") { Double.parser() }
        Field("capacityAt17") { Double.parser() }
      }
      .map(.case(HeatingInterpolation.Interpolation.heatPump))
    }
  }
  .map(.memberwise(HeatingInterpolation.Update.init(interpolation:)))
}
