import Dependencies
import Fluent
import ManualSModels
import SharedDatabase

extension SharedDatabase.Migrations {
  static func live() -> SharedDatabase.Migrations {
    .init {
      try await SharedDatabase.Migrations.liveValue.allMigrations() + [
        // Project currently get's created in shared database.
        // Project.Migrate(),  // Needs to stay at top / get created first.
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
