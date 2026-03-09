import Tagged

public typealias FlaggedCapacities = Tagged<TSLTag.FlaggedCapacity, TSLContainer<FlaggedState>>

public enum FlaggedState: String, Codable, Sendable {
  case success
  case failure

}

#if DEBUG
  extension FlaggedCapacities {
    public static let mock = Self(total: .failure, sensible: .success, latent: .failure)
  }
#endif
