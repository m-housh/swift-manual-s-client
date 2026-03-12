import Elementary
import ManualSModels
import SharedStyleguide
import Tagged

struct CoolingContainerFieldset: HTML, Sendable {

  private let title: String
  private let capacity: CoolingContainer<Double>?
  private let namePrefix: String?

  init(
    _ title: String = "Cooling Capacity",
    capacity: CoolingCapacity? = nil,
    namePrefix: String? = nil
  ) {
    self.title = title
    self.capacity = capacity?.rawValue
    self.namePrefix = namePrefix
  }

  init(
    _ title: String = "Cooling",
    load: CoolingLoad? = nil,
    namePrefix: String? = nil
  ) {
    self.title = title
    self.capacity = load?.rawValue
    self.namePrefix = namePrefix
  }

  var body: some HTML<HTMLTag.fieldset> {
    _CoolingContainerFieldset(
      title,
      container: capacity,
      namePrefix: namePrefix
    ) { value, name in

      label(.class("input w-full")) {
        span(.class("label")) { value.label }
        input(
          .type(.number),
          .name(name),
          .value(value.value),
          .min(0),
          .step(1),
          .required
        )
        span(.class("label")) { SVG(value.svg) }
      }
    }
  }
}

enum ContainerField<N>: Sendable where N: Sendable {
  case total(N?)
  case sensible(N?)

  fileprivate var label: String {
    switch self {
    case .total: return "Total"
    case .sensible: return "Sensible"
    }
  }

  var value: N? {
    switch self {
    case .total(let value): return value
    case .sensible(let value): return value
    }
  }
}

extension ContainerField where N == Double {
  fileprivate var svg: SVG.Key {
    switch self {
    case .total: return .leaf
    case .sensible: return .thermometerSnowflake
    }
  }
}

// FIX: ManufactuersAdjustments should also be able to use this, with a
//      custom style / more properties
private struct _CoolingContainerFieldset<N: Sendable, Field: HTML>: HTML {

  @Environment(CoolingContainerEnvironment.$style) var style

  let container: CoolingContainer<N>?
  let title: String
  let makeInputField: @Sendable (ContainerField<N>, String) -> Field
  let totalName: String
  let sensibleName: String

  init(
    _ title: String,
    container: CoolingContainer<N>? = nil,
    namePrefix: String? = nil,
    @HTMLBuilder makeInputField: @escaping @Sendable (ContainerField<N>, String) -> Field
  ) {
    self.title = title
    self.container = container
    self.totalName = namePrefix == nil ? "coolingTotal" : "\(namePrefix!)CoolingTotal"
    self.sensibleName = namePrefix == nil ? "coolingSensible" : "\(namePrefix!)CoolingSensible"
    self.makeInputField = makeInputField
  }

  var body: some HTML<HTMLTag.fieldset> {
    Fieldset(title) {
      div(.class("gap-4")) {
        makeInputField(.total(container?.total), totalName)
        makeInputField(.sensible(container?.sensible), sensibleName)
      }
      .attributes(contentsOf: style.attributes)
    }
  }
}

extension _CoolingContainerFieldset: Sendable where Field: Sendable {}

enum CoolingContainerFieldsetStyle {
  case hstack(gap: Int = 4)
  case vstack(gap: Int = 4)

  fileprivate var attributes: [HTMLAttribute<HTMLTag.div>] {
    switch self {
    case .hstack(let gap):
      return [.class("flex gap-\(gap)")]
    case .vstack(let gap):
      return [.class("space-y-\(gap)")]
    }
  }
}

private enum CoolingContainerEnvironment {
  @TaskLocal fileprivate static var style = CoolingContainerFieldsetStyle.hstack()
}

extension HTML {
  func coolingContainerFieldsetStyle(_ style: CoolingContainerFieldsetStyle) -> some HTML<Tag> {
    environment(CoolingContainerEnvironment.$style, style)
  }
}
