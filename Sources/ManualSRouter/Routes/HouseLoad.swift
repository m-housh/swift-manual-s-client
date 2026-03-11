import CasePathsCore
import FoundationEssentials
import ManualSModels
import SharedModels
import Tagged
@preconcurrency import URLRouting

extension HouseLoad {

  public enum ViewRoute: Sendable, Routeable {
    case index
    case submit(HouseLoad.Create)
    case update(HouseLoad.ID, HouseLoad.Update)

    static let path = "house-load"

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
            Field("heating") { Double.parser() }
            Field("coolingTotal") { Double.parser() }
            Field("coolingSensible") { Double.parser() }
          }
          .map(.memberwise(HouseLoad.Create.init))
        }
      }
      Route(.case(Self.update)) {
        Path {
          path
          HouseLoad.ID.parser()
        }
        Method.post
        Body {
          FormData {
            Optionally {
              Field("heating") { Double.parser() }
            }
            Optionally {
              Field("coolingTotal") { Double.parser() }
            }
            Optionally {
              Field("coolingSensible") { Double.parser() }
            }
          }
          .map(.memberwise(HouseLoad.Update.init))
        }
      }
    }
  }
}
