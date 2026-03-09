import ManualSModels
import Tagged

extension FlaggedCapacities {

  init(
    sizingLimits: SizingLimit.Cooling,
    capacityAsPercentOfLoad: CoolingInterpolation.Response.CapacityAsPercentOfLoad
  ) {
    self.init(
      total: .init(
        capacityAsPercentOfLoad.total,
        notAbove: sizingLimits.oversizing.total,
        notBelow: sizingLimits.undersizing.total
      ),
      sensible: .init(
        capacityAsPercentOfLoad.sensible,
        notAbove: capacityAsPercentOfLoad.sensible,
        notBelow: sizingLimits.undersizing.sensible
      ),
      latent: .init(
        capacityAsPercentOfLoad.latent,
        notAbove: sizingLimits.oversizing.latent,
        notBelow: sizingLimits.undersizing.latent
      )
    )
  }
}

extension FlaggedState {
  init<C>(
    _ comparing: C,
    notAbove: C?,
    notBelow: C
  ) where C: Comparable {
    if comparing < notBelow {
      self = .failure
    } else if let notAbove, comparing > notAbove {
      self = .failure
    } else {
      self = .success
    }
  }
}
