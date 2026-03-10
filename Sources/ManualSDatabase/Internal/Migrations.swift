import Dependencies
import Fluent
import ManualSModels
import SharedDatabase

extension SharedDatabase.Migrations {
  static func live() -> SharedDatabase.Migrations {
    .init {
      try await SharedDatabase.Migrations.liveValue.allMigrations() + [
        DesignInfo.Migrate(),
        HouseLoad.Migrate(),
        ProposedEquipment.Migrate(),
      ]
    }
  }
}
