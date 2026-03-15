import CasePathsCore
import FoundationEssentials
import ManualSModels
import Tagged
@preconcurrency import URLRouting

import protocol SharedModels.Routeable

extension CoolingInterpolation {

  public enum ViewRoute: Equatable, Sendable, Routeable {
    case index
    case result(CoolingInterpolation.ID)
    case submit(CoolingInterpolation.FormIntermediate)
    case update(CoolingInterpolation.ID, CoolingInterpolation.FormIntermediate)

    static let path = "cooling"

    public static let router = OneOf {
      Route(.case(Self.index)) {
        Path { path }
        Method.get
      }
      Route(.case(Self.result)) {
        Path {
          path
          CoolingInterpolation.ID.parser()
          "result"
        }
        Method.get
      }
      Route(.case(Self.submit)) {
        Path { path }
        Method.post
        CoolingInterpolation.FormIntermediate.router
      }
      Route(.case(Self.update)) {
        Path {
          path
          CoolingInterpolation.ID.parser()
        }
        Method.patch
        CoolingInterpolation.FormIntermediate.router
      }
    }
  }
}

extension CoolingInterpolation {
  public enum FormIntermediate: Equatable, Sendable {
    case noInterpolation(CoolingInterpolation.Interpolation.NoInterpolationIntermediate)
    case oneWayIndoor(CoolingInterpolation.Interpolation.OneWayIndoor.FormIntermediate)
    case oneWayOutdoor(CoolingInterpolation.Interpolation.OneWayOutdoor.FormIntermediate)
    case twoWay(CoolingInterpolation.Interpolation.TwoWay.FormIntermediate)

    static let router = OneOf {
      Route(.case(Self.noInterpolation)) {
        Body {
          CoolingInterpolation.Interpolation.NoInterpolationIntermediate.parser
        }
      }
      Route(.case(Self.oneWayIndoor)) {
        Body {
          CoolingInterpolation.Interpolation.OneWayIndoor.FormIntermediate.parser
        }
      }
      Route(.case(Self.oneWayOutdoor)) {
        Body {
          CoolingInterpolation.Interpolation.OneWayOutdoor.FormIntermediate.parser
        }
      }
      Route(.case(Self.twoWay)) {
        Body {
          CoolingInterpolation.Interpolation.TwoWay.FormIntermediate.parser
        }
      }
    }

    public func toCreate() -> CoolingInterpolation.Create {
      switch self {
      case .noInterpolation(let item): return item.toCreate()
      case .oneWayIndoor(let item): return item.toCreate()
      case .oneWayOutdoor(let item): return item.toCreate()
      case .twoWay(let item): return item.toCreate()
      }
    }

    public func toUpdate() -> CoolingInterpolation.Update {
      switch self {
      case .noInterpolation(let item): return item.toUpdate()
      case .oneWayIndoor(let item): return item.toUpdate()
      case .oneWayOutdoor(let item): return item.toUpdate()
      case .twoWay(let item): return item.toUpdate()
      }
    }
  }
}

extension CoolingInterpolation.Interpolation {
  public struct NoInterpolationIntermediate: Sendable, Equatable {

    static let parser = FormData {
      Field("projectID") { Project.ID.parser() }
      Field("coolingTotal") { Double.parser() }
      Field("coolingSensible") { Double.parser() }
      Field("manufacturersAdjustmentTotal") { Double.parser() }
      Field("manufacturersAdjustmentSensible") { Double.parser() }
      Field("designAirflow") { Int.parser() }
    }
    .map(.memberwise(CoolingInterpolation.Interpolation.NoInterpolationIntermediate.init))

    let projectID: Project.ID
    let coolingTotal: Double
    let coolingSensible: Double
    let manufacturersAdjustmentTotal: Double
    let manufacturersAdjustmentSensible: Double
    let designAirflow: Int

    public init(
      projectID: Project.ID,
      coolingTotal: Double,
      coolingSensible: Double,
      manufacturersAdjustmentTotal: Double,
      manufacturersAdjustmentSensible: Double,
      designAirflow: Int
    ) {
      self.projectID = projectID
      self.coolingTotal = coolingTotal
      self.coolingSensible = coolingSensible
      self.manufacturersAdjustmentTotal = manufacturersAdjustmentTotal
      self.manufacturersAdjustmentSensible = manufacturersAdjustmentSensible
      self.designAirflow = designAirflow
    }

    var manufacturersAdjustments: CoolingCapacityAdjustment {
      .init(
        total: .init(decimal: manufacturersAdjustmentTotal),
        sensible: .init(decimal: manufacturersAdjustmentSensible))
    }

    func toInterpolation() -> CoolingInterpolation.Interpolation {
      .noInterpolation(
        total: coolingTotal,
        sensible: coolingSensible
      )
    }

    func toCreate() -> CoolingInterpolation.Create {
      .init(
        projectID: projectID,
        designAirflow: designAirflow,
        interpolation: toInterpolation(),
        manufacturersAdjustments: manufacturersAdjustments
      )
    }

    func toUpdate() -> CoolingInterpolation.Update {
      .init(
        designAirflow: designAirflow,
        interpolation: toInterpolation(),
        manufacturersAdjustments: manufacturersAdjustments
      )
    }
  }
}

extension CoolingInterpolation.Interpolation.OneWayOutdoor {
  public struct FormIntermediate: Sendable, Equatable {

    fileprivate static let parser = FormData {
      Field("projectID") { Project.ID.parser() }
      Field("aboveDesignOutdoorTemperature") { Int.parser() }
      Field("aboveTotal") { Double.parser() }
      Field("aboveSensible") { Double.parser() }
      Field("belowDesignOutdoorTemperature") { Int.parser() }
      Field("belowTotal") { Double.parser() }
      Field("belowSensible") { Double.parser() }
      Field("manufacturersAdjustmentTotal") { Double.parser() }
      Field("manufacturersAdjustmentSensible") { Double.parser() }
      Field("designAirflow") { Int.parser() }
    }
    .map(.memberwise(CoolingInterpolation.Interpolation.OneWayOutdoor.FormIntermediate.init))

    let projectID: Project.ID
    let aboveDesignOutdoorTemperature: Int
    let aboveDesignTotalCapacity: Double
    let aboveDesignSensibleCapacity: Double
    let belowDesignOutdoorTemperature: Int
    let belowDesignTotalCapacity: Double
    let belowDesignSensibleCapacity: Double
    let manufacturersAdjustmentTotal: Double
    let manufacturersAdjustmentSensible: Double
    let designAirflow: Int

    public init(
      projectID: Project.ID,
      aboveDesignOutdoorTemperature: Int,
      aboveDesignTotalCapacity: Double,
      aboveDesignSensibleCapacity: Double,
      belowDesignOutdoorTemperature: Int,
      belowDesignTotalCapacity: Double,
      belowDesignSensibleCapacity: Double,
      manufacturersAdjustmentTotal: Double,
      manufacturersAdjustmentSensible: Double,
      designAirflow: Int
    ) {
      self.projectID = projectID
      self.aboveDesignOutdoorTemperature = aboveDesignOutdoorTemperature
      self.aboveDesignTotalCapacity = aboveDesignTotalCapacity
      self.aboveDesignSensibleCapacity = aboveDesignSensibleCapacity
      self.belowDesignOutdoorTemperature = belowDesignOutdoorTemperature
      self.belowDesignTotalCapacity = belowDesignTotalCapacity
      self.belowDesignSensibleCapacity = belowDesignSensibleCapacity
      self.manufacturersAdjustmentTotal = manufacturersAdjustmentTotal
      self.manufacturersAdjustmentSensible = manufacturersAdjustmentSensible
      self.designAirflow = designAirflow
    }

    var manufacturersAdjustments: CoolingCapacityAdjustment {
      .init(
        total: .init(decimal: manufacturersAdjustmentTotal),
        sensible: .init(decimal: manufacturersAdjustmentSensible))
    }

    func toInterpolation() -> CoolingInterpolation.Interpolation {
      .oneWayOutdoor(
        .init(
          aboveDesign: .init(
            outdoorTemperature: aboveDesignOutdoorTemperature,
            capacity: .init(total: aboveDesignTotalCapacity, sensible: aboveDesignSensibleCapacity)
          ),
          belowDesign: .init(
            outdoorTemperature: belowDesignOutdoorTemperature,
            capacity: .init(total: belowDesignTotalCapacity, sensible: belowDesignSensibleCapacity)
          )
        )
      )
    }

    func toCreate() -> CoolingInterpolation.Create {
      .init(
        projectID: projectID,
        designAirflow: designAirflow,
        interpolation: toInterpolation(),
        manufacturersAdjustments: manufacturersAdjustments)
    }

    func toUpdate() -> CoolingInterpolation.Update {
      .init(
        designAirflow: designAirflow,
        interpolation: toInterpolation(),
        manufacturersAdjustments: manufacturersAdjustments)
    }
  }
}

extension CoolingInterpolation.Interpolation.OneWayIndoor {
  public struct FormIntermediate: Sendable, Equatable {

    fileprivate static let parser = FormData {
      Field("projectID") { Project.ID.parser() }
      Field("aboveWetBulb") { Int.parser() }
      Field("aboveTotal") { Double.parser() }
      Field("aboveSensible") { Double.parser() }
      Field("belowWetBulb") { Int.parser() }
      Field("belowTotal") { Double.parser() }
      Field("belowSensible") { Double.parser() }
      Field("manufacturersAdjustmentTotal") { Double.parser() }
      Field("manufacturersAdjustmentSensible") { Double.parser() }
      Field("designAirflow") { Int.parser() }
    }
    .map(.memberwise(CoolingInterpolation.Interpolation.OneWayIndoor.FormIntermediate.init))

    let projectID: Project.ID
    let aboveDesignIndoorWetBulb: Int
    let aboveDesignTotalCapacity: Double
    let aboveDesignSensibleCapacity: Double
    let belowDesignIndoorWetBulb: Int
    let belowDesignTotalCapacity: Double
    let belowDesignSensibleCapacity: Double
    let manufacturersAdjustmentTotal: Double
    let manufacturersAdjustmentSensible: Double
    let designAirflow: Int

    public init(
      projectID: Project.ID,
      aboveDesignIndoorWetBulb: Int,
      aboveDesignTotalCapacity: Double,
      aboveDesignSensibleCapacity: Double,
      belowDesignIndoorWetBulb: Int,
      belowDesignTotalCapacity: Double,
      belowDesignSensibleCapacity: Double,
      manufacturersAdjustmentTotal: Double,
      manufacturersAdjustmentSensible: Double,
      designAirflow: Int
    ) {
      self.projectID = projectID
      self.aboveDesignIndoorWetBulb = aboveDesignIndoorWetBulb
      self.aboveDesignTotalCapacity = aboveDesignTotalCapacity
      self.aboveDesignSensibleCapacity = aboveDesignSensibleCapacity
      self.belowDesignIndoorWetBulb = belowDesignIndoorWetBulb
      self.belowDesignTotalCapacity = belowDesignTotalCapacity
      self.belowDesignSensibleCapacity = belowDesignSensibleCapacity
      self.manufacturersAdjustmentTotal = manufacturersAdjustmentTotal
      self.manufacturersAdjustmentSensible = manufacturersAdjustmentSensible
      self.designAirflow = designAirflow
    }

    func toInterpolation() -> CoolingInterpolation.Interpolation {
      .oneWayIndoor(
        .init(
          aboveDesign: .init(
            indoorWetBulbTemperature: aboveDesignIndoorWetBulb,
            capacity: .init(total: aboveDesignTotalCapacity, sensible: aboveDesignSensibleCapacity)
          ),
          belowDesign: .init(
            indoorWetBulbTemperature: belowDesignIndoorWetBulb,
            capacity: .init(total: belowDesignTotalCapacity, sensible: belowDesignSensibleCapacity)
          )
        )
      )
    }

    var manufacturersAdjustments: CoolingCapacityAdjustment {
      .init(
        total: .init(decimal: manufacturersAdjustmentTotal),
        sensible: .init(decimal: manufacturersAdjustmentSensible))
    }

    func toCreate() -> CoolingInterpolation.Create {
      .init(
        projectID: projectID,
        designAirflow: designAirflow,
        interpolation: toInterpolation(),
        manufacturersAdjustments: manufacturersAdjustments)
    }

    func toUpdate() -> CoolingInterpolation.Update {
      .init(
        designAirflow: designAirflow,
        interpolation: toInterpolation(),
        manufacturersAdjustments: manufacturersAdjustments)
    }
  }
}

extension CoolingInterpolation.Interpolation.TwoWay {
  public struct FormIntermediate: Equatable, Sendable {

    fileprivate static let parser = FormData {
      Field("projectID") { Project.ID.parser() }
      Field("aboveDesignOutdoorTemperature") { Int.parser() }
      Field("aboveDesignAboveIndoorWetBulb") { Int.parser() }
      Field("aboveDesignAboveTotalCapacity") { Double.parser() }
      Field("aboveDesignAboveSensibleCapacity") { Double.parser() }
      Field("aboveDesignBelowIndoorWetBulb") { Int.parser() }
      Field("aboveDesignBelowTotalCapacity") { Double.parser() }
      Field("aboveDesignBelowSensibleCapacity") { Double.parser() }
      Field("belowDesignOutdoorTemperature") { Int.parser() }
      Field("belowDesignAboveIndoorWetBulb") { Int.parser() }
      Field("belowDesignAboveTotalCapacity") { Double.parser() }
      Field("belowDesignAboveSensibleCapacity") { Double.parser() }
      Field("belowDesignBelowIndoorWetBulb") { Int.parser() }
      Field("belowDesignBelowTotalCapacity") { Double.parser() }
      Field("belowDesignBelowSensibleCapacity") { Double.parser() }
      Field("manufacturersAdjustmentTotal") { Double.parser() }
      Field("manufacturersAdjustmentSensible") { Double.parser() }
      Field("designAirflow") { Int.parser() }
    }
    .map(.memberwise(CoolingInterpolation.Interpolation.TwoWay.FormIntermediate.init))

    let projectID: Project.ID
    let aboveDesignOutdoorTemperature: Int
    let aboveDesignAboveIndoorWetBulb: Int
    let aboveDesignAboveTotalCapacity: Double
    let aboveDesignAboveSensibleCapacity: Double
    let aboveDesignBelowIndoorWetBulb: Int
    let aboveDesignBelowTotalCapacity: Double
    let aboveDesignBelowSensibleCapacity: Double
    let belowDesignOutdoorTemperature: Int
    let belowDesignAboveIndoorWetBulb: Int
    let belowDesignAboveTotalCapacity: Double
    let belowDesignAboveSensibleCapacity: Double
    let belowDesignBelowIndoorWetBulb: Int
    let belowDesignBelowTotalCapacity: Double
    let belowDesignBelowSensibleCapacity: Double
    let manufacturersAdjustmentTotal: Double
    let manufacturersAdjustmentSensible: Double
    let designAirflow: Int

    public init(
      projectID: Project.ID,
      aboveDesignOutdoorTemperature: Int,
      aboveDesignAboveIndoorWetBulb: Int,
      aboveDesignAboveTotalCapacity: Double,
      aboveDesignAboveSensibleCapacity: Double,
      aboveDesignBelowIndoorWetBulb: Int,
      aboveDesignBelowTotalCapacity: Double,
      aboveDesignBelowSensibleCapacity: Double,
      belowDesignOutdoorTemperature: Int,
      belowDesignAboveIndoorWetBulb: Int,
      belowDesignAboveTotalCapacity: Double,
      belowDesignAboveSensibleCapacity: Double,
      belowDesignBelowIndoorWetBulb: Int,
      belowDesignBelowTotalCapacity: Double,
      belowDesignBelowSensibleCapacity: Double,
      manufacturersAdjustmentTotal: Double,
      manufacturersAdjustmentSensible: Double,
      designAirflow: Int
    ) {
      self.projectID = projectID
      self.aboveDesignOutdoorTemperature = aboveDesignOutdoorTemperature
      self.aboveDesignAboveIndoorWetBulb = aboveDesignAboveIndoorWetBulb
      self.aboveDesignAboveTotalCapacity = aboveDesignAboveTotalCapacity
      self.aboveDesignAboveSensibleCapacity = aboveDesignAboveSensibleCapacity
      self.aboveDesignBelowIndoorWetBulb = aboveDesignBelowIndoorWetBulb
      self.aboveDesignBelowTotalCapacity = aboveDesignBelowTotalCapacity
      self.aboveDesignBelowSensibleCapacity = aboveDesignBelowSensibleCapacity
      self.belowDesignOutdoorTemperature = belowDesignOutdoorTemperature
      self.belowDesignAboveIndoorWetBulb = belowDesignAboveIndoorWetBulb
      self.belowDesignAboveTotalCapacity = belowDesignAboveTotalCapacity
      self.belowDesignAboveSensibleCapacity = belowDesignAboveSensibleCapacity
      self.belowDesignBelowIndoorWetBulb = belowDesignBelowIndoorWetBulb
      self.belowDesignBelowTotalCapacity = belowDesignBelowTotalCapacity
      self.belowDesignBelowSensibleCapacity = belowDesignBelowSensibleCapacity
      self.manufacturersAdjustmentTotal = manufacturersAdjustmentTotal
      self.manufacturersAdjustmentSensible = manufacturersAdjustmentSensible
      self.designAirflow = designAirflow
    }

    func toInterpolation() -> CoolingInterpolation.Interpolation {
      .twoWay(
        .init(
          aboveDesign: .init(
            outdoorTemperature: aboveDesignOutdoorTemperature,
            aboveWetBulb: .init(
              indoorWetBulbTemperature: aboveDesignAboveIndoorWetBulb,
              capacity: .init(
                total: aboveDesignAboveTotalCapacity, sensible: aboveDesignAboveSensibleCapacity)
            ),
            belowWetBulb: .init(
              indoorWetBulbTemperature: aboveDesignBelowIndoorWetBulb,
              capacity: .init(
                total: aboveDesignBelowTotalCapacity, sensible: aboveDesignBelowSensibleCapacity
              )
            )
          ),
          belowDesign: .init(
            outdoorTemperature: belowDesignOutdoorTemperature,
            aboveWetBulb: .init(
              indoorWetBulbTemperature: belowDesignAboveIndoorWetBulb,
              capacity: .init(
                total: belowDesignAboveTotalCapacity, sensible: belowDesignAboveSensibleCapacity)
            ),
            belowWetBulb: .init(
              indoorWetBulbTemperature: belowDesignBelowIndoorWetBulb,
              capacity: .init(
                total: belowDesignBelowTotalCapacity, sensible: belowDesignBelowSensibleCapacity
              )
            )
          )
        )
      )
    }

    var manufacturersAdjustments: CoolingCapacityAdjustment {
      .init(
        total: .init(decimal: manufacturersAdjustmentTotal),
        sensible: .init(decimal: manufacturersAdjustmentSensible))
    }

    func toCreate() -> CoolingInterpolation.Create {
      .init(
        projectID: projectID,
        designAirflow: designAirflow,
        interpolation: toInterpolation(),
        manufacturersAdjustments: manufacturersAdjustments)
    }

    func toUpdate() -> CoolingInterpolation.Update {
      .init(
        designAirflow: designAirflow,
        interpolation: toInterpolation(),
        manufacturersAdjustments: manufacturersAdjustments)
    }
  }
}
