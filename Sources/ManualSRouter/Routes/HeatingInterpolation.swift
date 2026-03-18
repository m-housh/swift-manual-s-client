import CasePathsCore
import FoundationEssentials
import ManualSModels
import Tagged
@preconcurrency import URLRouting

import struct SharedModels.Project
import protocol SharedModels.Routeable

// FIX: Need to be able to differentiate / mix and match updates and
//      creates, as it is possible to have one interpolation with an id (already created)
//      and the form to add other interpolation(s) during an edit.
extension HeatingInterpolation {
  public enum ViewRoute: Equatable, Sendable, Routeable {
    case index
    case submit(HeatingInterpolation.FormIntermediate)
    case update(HeatingInterpolation.FormIntermediate)

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
          HeatingInterpolation.FormIntermediate.parser
        }
      }
      Route(.case(Self.update)) {
        Path { path }
        Method.patch
        Body {
          HeatingInterpolation.FormIntermediate.parser
        }
      }
    }
  }
}

// FIX: Heat Pump form should also include kilowatt field
// extension HeatingInterpolation.Create {
//   static let parser = FormData {
//     Field("projectID") { Project.ID.parser() }
//     OneOf {
//       ParsePrint(.memberwise(HeatingInterpolation.Interpolation.BoilerOrFurnace.init)) {
//         Field("afue") { Percent.parser() }
//         Field("inputBTU") { Int.parser() }
//         Field("type") {
//           HeatingInterpolation.Interpolation.BoilerOrFurnace.BoilerOrFurnaceType.parser()
//         }
//       }
//       .map(.case(HeatingInterpolation.Interpolation.boilerOrFurnace))
//
//       ParsePrint(.case(HeatingInterpolation.Interpolation.electric)) {
//         Field("kilowatts") { Int.parser() }
//       }
//
//       ParsePrint(.memberwise(HeatPumpCapacity.init)) {
//         Field("capacityAt47") { Double.parser() }
//         Field("capacityAt17") { Double.parser() }
//       }
//       .map(.case(HeatingInterpolation.Interpolation.heatPump))
//     }
//   }
//   .map(.memberwise(HeatingInterpolation.Create.init(projectID:interpolation:)))
// }
//
// extension HeatingInterpolation.Update {
//   static let parser = FormData {
//     OneOf {
//       ParsePrint(.memberwise(HeatingInterpolation.Interpolation.BoilerOrFurnace.init)) {
//         Field("afue") { Percent.parser() }
//         Field("inputBTU") { Int.parser() }
//         Field("type") {
//           HeatingInterpolation.Interpolation.BoilerOrFurnace.BoilerOrFurnaceType.parser()
//         }
//       }
//       .map(.case(HeatingInterpolation.Interpolation.boilerOrFurnace))
//
//       ParsePrint(.case(HeatingInterpolation.Interpolation.electric)) {
//         Field("kilowatts") { Int.parser() }
//       }
//
//       ParsePrint(.memberwise(HeatPumpCapacity.init)) {
//         Field("capacityAt47") { Double.parser() }
//         Field("capacityAt17") { Double.parser() }
//       }
//       .map(.case(HeatingInterpolation.Interpolation.heatPump))
//     }
//   }
//   .map(.memberwise(HeatingInterpolation.Update.init(interpolation:)))
// }

extension HeatingInterpolation {
  public struct FormIntermediate: Equatable, Sendable {
    let projectID: Project.ID
    let boilerOrFurnaceID: HeatingInterpolation.ID?
    let electricID: HeatingInterpolation.ID?
    let heatPumpID: HeatingInterpolation.ID?
    let afue: Percent?
    let inputBTU: Int?
    let type: HeatingInterpolation.Interpolation.BoilerOrFurnace.BoilerOrFurnaceType?
    let capacityAt47: Double?
    let capacityAt17: Double?
    let kilowatts: Double?

    public init(
      projectID: Project.ID,
      boilerOrFurnaceID: HeatingInterpolation.ID? = nil,
      electricID: HeatingInterpolation.ID? = nil,
      heatPumpID: HeatingInterpolation.ID? = nil,
      afue: Percent? = nil,
      inputBTU: Int? = nil,
      type: HeatingInterpolation.Interpolation.BoilerOrFurnace.BoilerOrFurnaceType? = nil,
      capacityAt47: Double? = nil,
      capacityAt17: Double? = nil,
      kilowatts: Double? = nil
    ) {
      self.projectID = projectID
      self.boilerOrFurnaceID = boilerOrFurnaceID
      self.electricID = electricID
      self.heatPumpID = heatPumpID
      self.afue = afue
      self.inputBTU = inputBTU
      self.type = type
      self.capacityAt47 = capacityAt47
      self.capacityAt17 = capacityAt17
      self.kilowatts = kilowatts
    }

    private var boilerOrFurnaceInterpolation: HeatingInterpolation.Interpolation? {
      guard let afue, let inputBTU, let type else { return nil }
      return .boilerOrFurnace(.init(afue: afue, inputBTU: inputBTU, type: type))
    }

    private var electricInterpolation: HeatingInterpolation.Interpolation? {
      guard let kilowatts else { return nil }
      return .electric(kilowatts: Int(kilowatts))
    }

    private var heatPumpInterpolation: HeatingInterpolation.Interpolation? {
      guard let capacityAt17, let capacityAt47 else { return nil }
      return .heatPump(capacity: .init(capacityAt47: capacityAt47, capacityAt17: capacityAt17))
    }

    public func toCreate() -> [HeatingInterpolation.Create]? {
      var retval = [HeatingInterpolation.Create]()
      if let boilerOrFurnaceInterpolation {
        retval.append(
          .init(
            projectID: projectID,
            interpolation: boilerOrFurnaceInterpolation
          )
        )
      }
      if let electricInterpolation {
        retval.append(
          .init(
            projectID: projectID,
            interpolation: electricInterpolation
          )
        )
      }
      if let heatPumpInterpolation {
        retval.append(
          .init(
            projectID: projectID,
            interpolation: heatPumpInterpolation
          )
        )
      }

      return retval.count > 0
        ? retval
        : nil
    }

    public func toUpdate() -> [(HeatingInterpolation.ID, HeatingInterpolation.Update)]? {
      var retval = [(HeatingInterpolation.ID, HeatingInterpolation.Update)]()
      if let boilerOrFurnaceInterpolation, let boilerOrFurnaceID {
        retval.append(
          (
            boilerOrFurnaceID,
            HeatingInterpolation.Update(
              interpolation: boilerOrFurnaceInterpolation
            )
          )
        )
      }
      if let electricInterpolation, let electricID {
        retval.append(
          (
            electricID,
            HeatingInterpolation.Update(
              interpolation: electricInterpolation
            )
          )
        )
      }
      if let heatPumpInterpolation, let heatPumpID {
        retval.append(
          (
            heatPumpID,
            HeatingInterpolation.Update(
              interpolation: heatPumpInterpolation
            )
          )
        )
      }

      return retval.count > 0
        ? retval
        : nil
    }

    fileprivate static let parser = FormData {
      Field("projectID") { Project.ID.parser() }
      Optionally {
        Field("boilerOrFurnaceID") { HeatingInterpolation.ID.parser() }
      }
      Optionally {
        Field("electricID") { HeatingInterpolation.ID.parser() }
      }
      Optionally {
        Field("heatPumpID") { HeatingInterpolation.ID.parser() }
      }
      Optionally {
        Field("afue") { Percent.parser() }
      }
      Optionally {
        Field("inputBTU") { Int.parser() }
      }
      Optionally {
        Field("type") {
          HeatingInterpolation.Interpolation.BoilerOrFurnace.BoilerOrFurnaceType.parser()
        }
      }
      Optionally {
        Field("capacityAt47") { Double.parser() }
      }
      Optionally {
        Field("capacityAt17") { Double.parser() }
      }
      Optionally {
        Field("kilowatts") { Double.parser() }
      }
    }
    .map(.memberwise(FormIntermediate.init))
  }
}
