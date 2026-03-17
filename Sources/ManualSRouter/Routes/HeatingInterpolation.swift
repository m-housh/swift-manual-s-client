import CasePathsCore
import FoundationEssentials
import ManualSModels
import Tagged
@preconcurrency import URLRouting

import struct SharedModels.Project
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
      // TODO: Have a form type that can accept all the heating interpolation
      // values, so they can all be submitted together.
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
        Field("type") {
          HeatingInterpolation.Interpolation.BoilerOrFurnace.BoilerOrFurnaceType.parser()
        }
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
        Field("type") {
          HeatingInterpolation.Interpolation.BoilerOrFurnace.BoilerOrFurnaceType.parser()
        }
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

    public func toCreate() -> [HeatingInterpolation.Create]? {
      var retval = [HeatingInterpolation.Create]()
      if let afue, let inputBTU, let type {
        retval.append(
          .init(
            projectID: projectID,
            interpolation: .boilerOrFurnace(afue: afue, inputBTU: inputBTU, type: type)
          )
        )
      }
      if let kilowatts {
        retval.append(
          .init(
            projectID: projectID,
            interpolation: .electric(kilowatts: Int(kilowatts))
          )
        )
      }
      if let capacityAt17, let capacityAt47 {
        retval.append(
          .init(
            projectID: projectID,
            interpolation: .heatPump(
              capacity: .init(capacityAt47: capacityAt47, capacityAt17: capacityAt17))
          )
        )
      }

      return retval.count > 0
        ? retval
        : nil
    }

    public func toUpdate() -> [(HeatingInterpolation.ID, HeatingInterpolation.Update)]? {
      var retval = [(HeatingInterpolation.ID, HeatingInterpolation.Update)]()
      if let afue, let inputBTU, let type, let boilerOrFurnaceID {
        retval.append(
          (
            boilerOrFurnaceID,
            HeatingInterpolation.Update(
              interpolation: .boilerOrFurnace(afue: afue, inputBTU: inputBTU, type: type)
            )
          )
        )
      }
      if let kilowatts, let electricID {
        retval.append(
          (
            electricID,
            HeatingInterpolation.Update(
              interpolation: .electric(kilowatts: Int(kilowatts))
            )
          )
        )
      }
      if let capacityAt17, let capacityAt47, let heatPumpID {
        retval.append(
          (
            heatPumpID,
            HeatingInterpolation.Update(
              interpolation: .heatPump(
                capacity: .init(capacityAt47: capacityAt47, capacityAt17: capacityAt17)
              )
            )
          )
        )
      }

      return retval.count > 0
        ? retval
        : nil
    }
  }
}
