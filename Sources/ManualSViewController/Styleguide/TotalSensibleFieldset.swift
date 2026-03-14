import Elementary
import ManualSModels
import SharedStyleguide
import Tagged

struct TotalSensibleFieldset: HTML, Sendable {

  let title: String?
  let namePrefix: String?
  let container: FieldsetInput

  init(
    _ container: FieldsetInput,
    title: String? = nil,
    namePrefix: String? = nil
  ) {
    self.container = container
    self.title = title
    self.namePrefix = namePrefix
  }

  private var strongNamePrefix: String { namePrefix ?? container.namePrefix }
  private var totalName: String { "\(strongNamePrefix)Total" }
  private var sensibleName: String { "\(strongNamePrefix)Sensible" }

  var body: some HTML<HTMLTag.fieldset> {

    Fieldset(title ?? container.title) {
      switch container {
      case .coolingLoad(let load):
        makeInputField(.total(load?.rawValue.total), totalName)
        makeInputField(.sensible(load?.rawValue.sensible), sensibleName)
      case .coolingCapacity(let capacity):
        makeInputField(.total(capacity?.rawValue.total), totalName)
        makeInputField(.sensible(capacity?.rawValue.sensible), sensibleName)
      case .manufacturersAdjustments(let adjustments):
        makeInputField(.total(adjustments?.rawValue.total), totalName)
        makeInputField(.sensible(adjustments?.rawValue.sensible), sensibleName)
      }
    }
  }

}

extension TotalSensibleFieldset {

  enum FieldsetInput: Sendable {
    case coolingCapacity(CoolingCapacity? = nil)
    case coolingLoad(CoolingLoad? = nil)
    case manufacturersAdjustments(CoolingCapacityAdjustment? = nil)

    fileprivate var title: String {
      switch self {
      case .coolingCapacity(_): return "Cooling Capacity"
      case .coolingLoad(_): return "Cooling"
      case .manufacturersAdjustments(_): return "Manufacturer's Adjustments"
      }
    }

    fileprivate var namePrefix: String {
      switch self {
      case .coolingCapacity(_): return "cooling"
      case .coolingLoad(_): return "cooling"
      case .manufacturersAdjustments(_): return "manufacturersAdjustment"
      }
    }
  }
}

private enum ContainerField<N>: Sendable where N: Sendable {
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

private func makeInputField(_ value: ContainerField<Double>, _ name: String) -> some HTML {
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

private func makeInputField(_ value: ContainerField<Percent>, _ name: String) -> some HTML {
  PercentField(
    value.label,
    percent: value.value,
    inputAttributes: .name(name)
  )
}
