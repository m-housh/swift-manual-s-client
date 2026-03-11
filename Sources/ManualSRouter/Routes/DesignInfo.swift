import CasePathsCore
import FoundationEssentials
import ManualSModels
import SharedModels
import Tagged
@preconcurrency import URLRouting

extension DesignInfo {
  public enum ViewRoute: Equatable, Sendable, Routeable {
    case index
    case submit(DesignInfo.Create)
    case update(DesignInfo.ID, DesignInfo.Update)

    static let path = "design-info"

    static let idParser = From(.utf8) {
      UUID.parser().map(.representing(DesignInfo.ID.self))
    }

    public static let router = OneOf {
      Route(.case(Self.index)) {
        Path { path }
        Method.get
      }
      Route(.case(Self.submit)) {
        Path { path }
        Method.post
        Body {
          FormData {
            Field("projectID") { Project.ID.parser() }
            Field("elevation") { Int.parser() }
            Field("summerOutdoorTemperature") { Int.parser() }
            Field("summerIndoorTemperature") { Int.parser() }
            Field("summerIndoorHumidity") { Percent.parser() }
            Field("winterOutdoorTemperature") { Int.parser() }
          }
          .map(.memberwise(DesignInfo.Create.init))
        }
      }
      Route(.case(Self.update)) {
        Path {
          path
          DesignInfo.ID.parser()
        }
        Method.patch
        Body {
          FormData {
            Optionally {
              Field("elevation") { Int.parser() }
            }
            Optionally {
              Field("summerOutdoorTemperature") { Int.parser() }
            }
            Optionally {
              Field("summerIndoorTemperature") { Int.parser() }
            }
            Optionally {
              Field("summerIndoorHumidity") { Percent.parser() }
            }
            Optionally {
              Field("winterOutdoorTemperature") { Int.parser() }
            }
          }
          .map(.memberwise(DesignInfo.Update.init))
        }
      }
    }

  }
}
