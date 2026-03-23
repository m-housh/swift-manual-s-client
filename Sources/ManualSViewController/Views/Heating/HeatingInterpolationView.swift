import Elementary
import ManualSModels
import SharedStyleguide

struct HeatingInterpolationsView: HTML, Sendable {
  let projectID: Project.ID
  let interpolations: [(HeatingInterpolation, HeatingInterpolation.Response)]

  var body: some HTML {
    Table {
      tbody {
        for item in interpolations {
          Row(item.0, item.1)
        }
      }
    }
    .temperatureViewStyle(digits: 1)
    .percentViewSymbolStyle(.default)

    // MARK: - Cards
    div(.class("space-y-6")) {
      if let (interpolation, response) = interpolations.first(where: { $0.1.gasOrBoiler != nil }),
        let gasFurnace = interpolation.boilerOrFurnace
      {
        ResponseCard(
          "Gas - \(gasFurnace.type.rawValue.capitalized)",
          flag: response.gasOrBoiler?.flag
        ) {
          div(.class("grid grid-cols-2 m-6 justify-center items-center")) {
            div(.class("grid grid-cols-2 gap-4 mx-auto")) {
              Group {
                span(.class("label")) { "Input" }
                NumberView(gasFurnace.inputBTU)
              }
              if let response = response.gasOrBoiler {
                Group {
                  span(.class("label")) { "Altitude Adjustment" }
                  PercentView(response.altitudeDerating ?? .init(decimal: 1.0))
                    .percentViewStyle(.decimal)
                    .percentViewSymbolStyle(.none)
                }
                Group {
                  span(.class("label")) { "Final Capacity" }
                  NumberView(response.finalCapacity)
                }
              }
            }
            div(.class("grid grid-cols-2 gap-4 mx-auto")) {
              Group {
                span(.class("label")) { "AFUE" }
                PercentView(gasFurnace.afue)
              }
              if let response = response.gasOrBoiler {
                Group {
                  span(.class("label")) { "Oversizing Limit" }
                  PercentView(Percent(Double(response.sizingLimits.oversizing)))
                }
                Group {
                  span(.class("label")) { "Percent of Load" }
                  PercentView(response.percentOfLoad)
                }
              }
            }
            .percentViewStyle(.default)
            .percentViewSymbolStyle(.default)
          }
        }
      }

      if let (interpolation, response) = interpolations.first(where: { $0.1.electric != nil }),
        let electric = interpolation.electric
      {

        ResponseCard(
          "Electric",
          flag: response.electric?.kwFlag(Double(electric))
        ) {
          if let response = response.electric {
            div(.class("grid grid-cols-2 m-6 justify-center")) {
              div(.class("grid grid-cols-2 gap-4 mx-auto")) {
                Group {
                  div {}
                  div {}
                }
                Group {
                  span(.class("label")) { "Required KW" }
                  NumberView(response.requiredKW)
                }
                Group {
                  span(.class("label")) { "Proposed KW" }
                  NumberView(electric)
                }
              }
              div(.class("grid grid-cols-2 gap-4 mx-auto")) {
                Group {
                  span(.class("label")) { "Undersizing Limit" }
                  PercentView(Percent(response.sizingLimits.undersizing))
                }
                Group {
                  span(.class("label")) { "Oversizing Limit" }
                  PercentView(Percent(response.sizingLimits.oversizing))
                }
                Group {
                  span(.class("label")) { "Percent of Load" }
                  PercentView(response.percentOfLoad)
                }
              }
              .percentViewStyle(.default)
              .percentViewSymbolStyle(.default)
            }
          }
        }
      }

      if let (interpolation, response) = interpolations.first(where: { $0.1.heatPump != nil }),
        let heatPump = interpolation.heatPump
      {
        ResponseCard(
          "Heat Pump"
        ) {
          if let response = response.heatPump {
            div(.class("grid grid-cols-2 m-6 justify-center")) {
              // lhs
              div(.class("grid grid-cols-2 gap-4 mx-auto")) {
                Group {
                  span(.class("label")) { "Capacity @ 47" }
                  NumberView(heatPump.capacityAt47)
                }
                Group {
                  span(.class("label")) { "Altitude Adjustment" }
                  PercentView(response.deratings)
                    .percentViewStyle(.decimal)
                    .percentViewSymbolStyle(.none)
                }
                Group {
                  span(.class("label")) { "Final Capacity @ 47" }
                  NumberView(response.finalCapacity.capacityAt47)
                }
                Group {
                  span(.class("label")) { "Capacity @ Design" }
                  NumberView(response.capacityAtDesign, digits: 0)
                }
              }

              // rhs
              div(.class("grid grid-cols-2 gap-4 mx-auto")) {
                Group {
                  span(.class("label")) { "Capacity @ 17" }
                  NumberView(heatPump.capacityAt17)
                }
                Group {
                  span(.class("label")) { "Altitude Adjustment" }
                  PercentView(response.deratings)
                    .percentViewStyle(.decimal)
                    .percentViewSymbolStyle(.none)
                }
                Group {
                  span(.class("label")) { "Final Capacity @ 17" }
                  NumberView(response.finalCapacity.capacityAt17)
                }
                Group {
                  span(.class("label")) { "Balance Point" }
                  TemperatureView(response.balancePointTemperature)
                }
              }
            }
          }
        }
      }
    }

  }

  struct Row: HTML, Sendable {
    let interpolation: HeatingInterpolation
    let response: HeatingInterpolation.Response

    init(_ interpolation: HeatingInterpolation, _ response: HeatingInterpolation.Response) {
      self.interpolation = interpolation
      self.response = response
    }

    var body: some HTML {
      switch interpolation.interpolation {
      case .heatPump(let capacity):
        heatPumpRows(capacity, response)
      case .electric(let kilowatts):
        electricRows(Double(kilowatts))
      case .boilerOrFurnace(let boilerOrFurnace):
        boilerOrFurnaceRows(boilerOrFurnace)
      }
    }

    @HTMLBuilder
    private func electricRows(_ kilowatts: Double) -> some HTML {
      // Header
      makeRow(
        .text("Electric", attributes: [.class("text-xl")]),
        .label("Required KW"),
        .label("Proposed KW")
      )
      .style(.bold, .label)

      if let response = response.electric {
        makeRow(
          nil,
          .double(response.requiredKW),
          .flagged(kilowatts, response.kwFlag(kilowatts))
        )
        makeRow(
          nil,
          .label("Percent of Required"),
          .label("Oversizing Limit")
        )
        .style(.bold, .label)
        makeRow(
          nil,
          .percent(response.percentOfLoad),
          .percent(Percent(Double(response.sizingLimits.oversizing)))
        )
      }
    }

    @HTMLBuilder
    private func heatPumpRows(
      _ capacity: HeatPumpCapacity,
      _ response: HeatingInterpolation.Response
    ) -> some HTML {
      // Header
      makeRow {
        span(.class("text-xl")) { "Heat Pump" }
      } columnB: {
        div(.class("flex gap-2")) {
          span { "@" }
          TemperatureView(47)
        }
      } columnC: {
        div(.class("flex gap-2")) {
          span { "@" }
          TemperatureView(17)
        }
      }
      .style(.bold, .label)

      makeRow(
        .label("Capacity"),
        .double(capacity.capacityAt47),
        .double(capacity.capacityAt17)
      )
      if let response = response.heatPump {
        makeRow(
          .label("Altitude Deratings"),
          .percent(response.deratings),
          .percent(response.deratings)
        )
        .percentViewStyle(.decimal)
        .percentViewSymbolStyle(.none)

        makeRow(
          .label("Final Capacity"),
          .double(response.finalCapacity.capacityAt47),
          .double(response.finalCapacity.capacityAt17)
        )
        makeRow(
          nil,
          .label("Capacity @ Design"),
          .label("Balance Point Temperature")
        )
        .style(.label, .bold)

        makeRow(
          nil,
          .double(response.capacityAtDesign),
          .temperature(response.balancePointTemperature)
        )
      }
    }

    @HTMLBuilder
    private func boilerOrFurnaceRows(
      _ interpolation: HeatingInterpolation.Interpolation.BoilerOrFurnace
    ) -> some HTML {
      // Header
      makeRow(
        .text("Gas - \(interpolation.type.rawValue.capitalized)", attributes: [.class("text-xl")]),
        .text("BTU/h"),
        .text("AFUE"),
      )
      .style(.label, .bold)
      makeRow(
        .label("Input"),
        .double(Double(interpolation.inputBTU)),
        .percent(interpolation.afue)
      )
      if let response = response.gasOrBoiler {
        // makeRow(
        //   .label("Output"),
        //   .double(Double(response.outputCapacity)),
        //   nil,
        // )

        makeRow(
          .label("Altitude Adjustment"),
          .percent(response.altitudeDerating ?? .init(decimal: 1.0)),
          nil,
        )
        .percentViewStyle(.decimal)
        .percentViewSymbolStyle(.none)

        makeRow(
          .label("Final Capacity"),
          .flagged(Double(response.finalCapacity), response.flag),
          nil
          // .percent(Percent(Double(response.sizingLimits.oversizing)))
        )

        makeRow(
          nil,
          .label("Percent of Load"),
          .label("Oversizing Limit")
        )

        makeRow(
          nil,
          .percent(response.percentOfLoad),
          .percent(Percent(Double(response.sizingLimits.oversizing)))
        )
      }
    }

    func makeRow<
      ColumnA: HTML,
      ColumnB: HTML,
      ColumnC: HTML
    >(
      @HTMLBuilder columnA: () -> ColumnA,
      @HTMLBuilder columnB: () -> ColumnB,
      @HTMLBuilder columnC: () -> ColumnC
    ) -> some HTML<HTMLTag.tr> {
      tr {
        td { columnA() }
        td { columnB() }
        td { columnC() }
      }
    }

    func makeRow(
      _ columnA: Column?,
      _ columnB: Column?,
      _ columnC: Column?
    ) -> some HTML<HTMLTag.tr> {
      makeRow {
        if let columnA {
          columnA
        }
      } columnB: {
        if let columnB {
          columnB
        }
      } columnC: {
        if let columnC {
          columnC
        }
      }
    }

    enum Column: HTML, Sendable {
      case double(Double)
      case flagged(Double, FlaggedState)
      case label(String, attributes: [HTMLAttribute<HTMLTag.span>] = [])
      case percent(Percent)
      case temperature(Double)
      case text(String, attributes: [HTMLAttribute<HTMLTag.span>] = [])

      var body: some HTML {
        switch self {
        case .double(let double):
          NumberView(double)
        case .flagged(let double, let flag):
          FlaggedView(flag) {
            NumberView(double)
          }
        case .percent(let percent):
          PercentView(percent)
        case .label(let label, let attributes):
          span(.class("label")) { label }
            .attributes(contentsOf: attributes)
        case .temperature(let temperature):
          TemperatureView(temperature)
        case .text(let text, let attributes):
          span { text }
            .attributes(contentsOf: attributes)
        }
      }
    }
  }

}

private struct ResponseCard<Content: HTML>: HTML {
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
extension ResponseCard: Sendable where Content: Sendable {}

extension HeatingInterpolation.Response.Electric {

  func kwFlag(_ kw: Double) -> FlaggedState {
    if percentOfLoad > 175 { return .failure }
    return .success
  }
}

extension HeatingInterpolation.Response.GasOrBoiler {
  var flag: FlaggedState {
    let percentOfLoad = Int(percentOfLoad.rawValue)
    if percentOfLoad < sizingLimits.undersizing || percentOfLoad > sizingLimits.oversizing {
      return .failure
    }
    return .success
  }
}

extension HTMLTag.tr: TextStylable {}
