import Dependencies
import Fluent
import ManualSModels
import SharedDatabase

extension SharedDatabase.Migrations {
  static func live() -> SharedDatabase.Migrations {
    .init {
      try await SharedDatabase.Migrations.liveValue.allMigrations() + [
        CoolingInterpolation.Migrate(),
        DesignInfo.Migrate(),
        HeatingInterpolation.Migrate(),
        HouseLoad.Migrate(),
        ProposedEquipment.Migrate(),
        SystemType.Migrate(),
      ]
    }
  }
}
