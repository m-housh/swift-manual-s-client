import Elementary
import ManualSModels
import SharedStyleguide

struct HeatingInterpolationsView: HTML, Sendable {
  let projectID: Project.ID
  let interpolations: [ProjectDetailsAndInterpolations.HeatingInterpolationContainer]

  var body: some HTML {
    div(.class("space-y-6 mt-6")) {
      if let container = interpolations.first(where: { $0.response.gasOrBoiler != nil }),
        let gasFurnace = container.interpolation.boilerOrFurnace,
        let response = container.response.gasOrBoiler
      {
        ResponseCard(
          "Gas - \(gasFurnace.type.rawValue.capitalized)",
          flag: response.flag
        ) {
          div(.class("grid grid-cols-2 m-6 justify-center items-center")) {
            div(.class("grid grid-cols-2 gap-4 mx-auto")) {
              Row("Input", number: gasFurnace.inputBTU)
              Row("Altitude Adjustment", percent: response.altitudeDerating ?? .init(decimal: 1.0))
              Row("Final Capacity", number: response.finalCapacity)
            }
            .percentViewStyle(.decimal)
            .percentViewSymbolStyle(.none)

            div(.class("grid grid-cols-2 gap-4 mx-auto")) {
              Row("AFUE", percent: gasFurnace.afue)
              Row("Undersizing Limit", percent: response.sizingLimits.undersizing)
              Row("Oversizing Limit", percent: response.sizingLimits.oversizing)
              Row("Percent of Load", percent: response.percentOfLoad)
            }
          }
        }
        .percentViewStyle(.default)
        .percentViewSymbolStyle(.default)
      }

      if let container = interpolations.first(where: { $0.response.electric != nil }),
        let electric = container.interpolation.electric,
        let response = container.response.electric
      {

        ResponseCard(
          "Electric",
          flag: response.kwFlag(Double(electric))
        ) {
          div(.class("grid grid-cols-2 m-6 justify-center")) {
            // lhs
            div(.class("grid grid-cols-2 gap-4 mx-auto")) {
              div(.class("col-span-2")) {}
              Row("Required KW", number: response.requiredKW, digits: 1)
              Row("Proposed KW", number: electric)
            }
            // rhs
            div(.class("grid grid-cols-2 gap-4 mx-auto")) {
              Row("Undersizing Limit", percent: response.sizingLimits.undersizing)
              Row("Oversizing Limit", percent: response.sizingLimits.oversizing)
              Row("Percent of Load", percent: response.percentOfLoad)
            }
            .percentViewStyle(.default)
            .percentViewSymbolStyle(.default)
          }
        }
      }

      if let container = interpolations.first(where: { $0.response.heatPump != nil }),
        let heatPump = container.interpolation.heatPump,
        let response = container.response.heatPump
      {
        ResponseCard(
          "Heat Pump"
        ) {
          div(.class("grid grid-cols-2 m-6 justify-center")) {
            // lhs
            div(.class("grid grid-cols-2 gap-4 mx-auto")) {
              div(.class("flex label font-bold col-span-2 text-center mx-auto")) {
                TemperatureView(47)
              }
              Row("Capacity", number: heatPump.capacityAt47)
              Row("Altitude Adjustment", percent: response.deratings)
              Row("Final Capacity", number: response.finalCapacity.capacityAt47)
              Row("Capacity at Design", number: response.capacityAtDesign)
            }
            .percentViewStyle(.decimal)
            .percentViewSymbolStyle(.none)

            // rhs
            div(.class("grid grid-cols-2 gap-4 mx-auto")) {
              div(.class("flex label font-bold col-span-2 text-center mx-auto")) {
                TemperatureView(17)
              }
              Row("Capacity", number: heatPump.capacityAt17)
              Row("Altitude Adjustment", percent: response.deratings)
              Row("Final Capacity", number: response.finalCapacity.capacityAt17)
              Row("Balance Point", temperature: response.balancePointTemperature)
            }
            .percentViewStyle(.decimal)
            .percentViewSymbolStyle(.none)
          }
        }
      }
    }
  }

  fileprivate struct ResponseCard<Content: HTML>: HTML {
    let title: String
    let flag: FlaggedState?
    let _content: Content

    init(
      _ title: String,
      flag: FlaggedState? = nil,
      @HTMLBuilder body: () -> Content
    ) {
      self.title = title
      self.flag = flag
      self._content = body()
    }

    var body: some HTML<HTMLTag.div> {
      div(.class("border rounded-box p-6")) {
        div(.class("flex justify-between")) {
          h2(.class("text-2xl font-bold label")) { title }
          if let flag {
            FlaggedView(flag) {}
          }
        }
        _content
      }
    }
  }

  fileprivate struct Row<Label: HTML, Content: HTML>: HTML {
    let label: Label
    let _body: Content

    init(
      @HTMLBuilder label: () -> Label,
      @HTMLBuilder content: () -> Content
    ) {
      self.label = label()
      self._body = content()
    }

    var body: some HTML {
      label
      _body
    }
  }
}
extension HeatingInterpolationsView.ResponseCard: Sendable where Content: Sendable {}
extension HeatingInterpolationsView.Row: Sendable where Label: Sendable, Content: Sendable {}

extension HeatingInterpolationsView.Row where Label == span<HTMLText> {
  init(_ label: String, @HTMLBuilder content: () -> Content) {
    self.init(
      label: { span(.class("label")) { label } },
      content: content
    )
  }
}
extension HeatingInterpolationsView.Row where Label == span<HTMLText>, Content == TemperatureView {
  init(_ label: String, temperature: Double) {
    self.init(label, content: { TemperatureView(temperature) })
  }
}

extension HeatingInterpolationsView.Row where Label == span<HTMLText>, Content == PercentView {
  init(_ label: String, percent: Percent) {
    self.init(label, content: { PercentView(percent) })
  }
}

extension HeatingInterpolationsView.Row where Label == span<HTMLText>, Content == NumberView {
  init(_ label: String, number: Double, digits: Int = 0) {
    self.init(label, content: { NumberView(number, digits: digits) })
  }

  init(_ label: String, number: Int) {
    self.init(label, content: { NumberView(number) })
  }
}

extension HeatingInterpolation.Response.Electric {

  func kwFlag(_ kw: Double) -> FlaggedState {
    if percentOfLoad > 175 { return .failure }
    return .success
  }
}

extension HeatingInterpolation.Response.GasOrBoiler {
  var flag: FlaggedState {
    // let percentOfLoad = Int(percentOfLoad.rawValue)
    if percentOfLoad < sizingLimits.undersizing || percentOfLoad > sizingLimits.oversizing {
      return .failure
    }
    return .success
  }
}

extension HTMLTag.tr: TextStylable {}
