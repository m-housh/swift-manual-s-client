public enum SystemType: Codable, Equatable, Sendable {

  case heatingOnly(Heating)

  public enum Heating: String, CaseIterable, Codable, Equatable, Sendable {
    case boiler
    case electric
    case furnace
  }
}
