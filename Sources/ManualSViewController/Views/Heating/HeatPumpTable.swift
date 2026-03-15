import Elementary
import ManualSModels
import SharedModels
import SharedStyleguide
import Tagged

struct HeatPumpTable: HTML, Sendable {

  let inputCapacity: HeatPumpCapacity
  let response: HeatingInterpolation.Response

  var body: some HTML<HTMLTag.table> {
    Table {
      thead {
        tr {
          th {}
          th { "@ 47°" }
          th { "@ 17°" }
        }
      }
      tbody {
        Row(label: "Capacity", capacity: inputCapacity)
        if let response = response.heatPump {
          Row(
            "Altitude Deratings",
            .percent(response.deratings),
            .percent(response.deratings)
          )
          .percentViewStyle(.decimal)

          Row(label: "Final Capacity", capacity: response.finalCapacity)

          Row(
            nil,
            .string("Capacity @ Design"),
            .string("Balance Point Temperature")
          )
          .style(.bold, .label)

          // Fix: this should be flagged.
          Row(
            nil,
            .double(response.capacityAtDesign),
            .double(response.balancePointTemperature)
          )
        }
      }
    }
  }

  struct Row: HTML, Sendable {

    @Environment(HeatPumpTableEnvironment.$rowStyle) var rowStyle

    let label: String?
    let colA: Column?
    let colB: Column?

    init(
      _ label: String?,
      _ colA: Column?,
      _ colB: Column?
    ) {
      self.label = label
      self.colA = colA
      self.colB = colB
    }

    init(
      label: String?,
      capacity: HeatPumpCapacity
    ) {
      self.init(
        label,
        .double(capacity.capacityAt47),
        .double(capacity.capacityAt47)
      )
    }

    var body: some HTML<HTMLTag.tr> {
      tr {
        td(.class("label")) {
          if let label {
            HTMLText(label)
          }
        }
        td {
          if let colA {
            colA
          }
        }
        td {
          if let colB {
            colB
          }
        }
      }
      .style(rowStyle)
    }
  }
}

extension HeatPumpTable.Row {
  enum Column: HTML, Sendable {
    case string(String)
    case double(Double)
    case percent(Percent)

    var body: some HTML {
      switch self {
      case .string(let string):
        HTMLText(string)
      case .double(let double):
        NumberView(double)
      case .percent(let percent):
        PercentView(percent)
      }
    }
  }
}

extension HeatPumpTable {
  typealias RowStyle = Tagged<Row, Style<HTMLTag.tr>>
}

extension HTMLTag.tr: TextStylable {}

private enum HeatPumpTableEnvironment {
  @TaskLocal static var rowStyle: HeatPumpTable.RowStyle = .init()
}

extension HTML {
  func heatPumpRowStyle(_ style: HeatPumpTable.RowStyle) -> some HTML<Tag> {
    environment(HeatPumpTableEnvironment.$rowStyle, style)
  }
}
