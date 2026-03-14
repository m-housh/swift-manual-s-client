import Elementary
import ElementaryHTMX
import Foundation
import ManualSModels
import ManualSRouter
import SharedModels
import SharedStyleguide

struct TwoWayForm: HTML, Sendable {
  let projectID: Project.ID
  let outdoorDesignTemperature: Double
  let interpolation: CoolingInterpolation?

  init(
    projectID: Project.ID,
    outdoorDesignTemperature: Double,
    interpolation: CoolingInterpolation? = nil
  ) {
    self.projectID = projectID
    self.outdoorDesignTemperature = outdoorDesignTemperature
    self.interpolation = interpolation
  }

  private var route: String {
    ManualSRoute.router.path(for: .projectDetail(projectID, .interpolations(.cooling(.index))))
      .appendingPath(interpolation?.id)
  }

  private var twoWay: CoolingInterpolation.Interpolation.TwoWay? {
    interpolation?.twoWay
  }

  var body: some HTML<HTMLTag.form> {
    Form(
      title: "Two Way",
      interpolation == nil
        ? .hx.post(route)
        : .hx.patch(route),
      .hx.target(id: ProjectDetailsView.Section.id(.coolingInterpolation())),
      .hx.swap(.outerHTML)
    ) {

      input(.hidden, .name("projectID"), .value(projectID))

      DesignAirflowFieldset(designAirflow: interpolation?.designAirflow)

      Fieldset("Below") {
        div(.class("flex items-center space-x-2")) {
          span { SVG(.thermometerSun) }
          span(.class("label")) { "Outdoor Temperature:" }
          NumberView(belowOutdoorTemp)
            .attributes(.class("font-bold"))
        }
        makeFieldset(
          title: "Below Wet Bulb",
          wetBulb: twoWay?.belowDesign.belowWetBulb.indoorWetBulbTemperature ?? 62,
          capacity: twoWay?.belowDesign.belowWetBulb.capacity,
          namePrefix: "belowDesignBelow"
        )

        makeFieldset(
          title: "Above Wet Bulb",
          wetBulb: twoWay?.belowDesign.aboveWetBulb.indoorWetBulbTemperature ?? 67,
          capacity: twoWay?.belowDesign.aboveWetBulb.capacity,
          namePrefix: "belowDesignAbove"
        )

      }
      .fieldsetStyle(.twoWayFormStyle)

      Fieldset("Above") {
        div(.class("flex items-center space-x-2")) {
          span { SVG(.thermometerSun) }
          span(.class("label")) { "Outdoor Temperature:" }
          NumberView(aboveOutdoorTemp)
            .attributes(.class("font-bold"))
        }
        makeFieldset(
          title: "Below Wet Bulb",
          wetBulb: twoWay?.aboveDesign.belowWetBulb.indoorWetBulbTemperature ?? 62,
          capacity: twoWay?.aboveDesign.belowWetBulb.capacity,
          namePrefix: "aboveDesignBelow"
        )

        makeFieldset(
          title: "Above Wet Bulb",
          wetBulb: twoWay?.aboveDesign.aboveWetBulb.indoorWetBulbTemperature ?? 67,
          capacity: twoWay?.aboveDesign.aboveWetBulb.capacity,
          namePrefix: "aboveDesignAbove"
        )
      }
      .fieldsetStyle(.twoWayFormStyle)

    }
  }

  private func makeFieldset(
    title: String,
    wetBulb: Int,
    capacity: CoolingCapacity?,
    namePrefix: String
  ) -> some HTML {
    Fieldset(title) {
      label(.class("input w-full")) {
        span(.class("label")) { SVG(.droplets) }
        input(
          .type(.number),
          .name("\(namePrefix)WetBulb"),
          .value(wetBulb),
          .min(0),
          .step(1),
          .required
        )
        span(.class("label")) { "Wet Bulb" }
      }
      TotalSensibleFieldset(
        .coolingCapacity(capacity),
        namePrefix: namePrefix
      )
      .fieldsetStyle(.plain)
    }
    .fieldsetStyle(.roundedBox)
  }

  private var belowOutdoorTemp: Double {
    let evenDecimal = floor(outdoorDesignTemperature / 10)
    return (evenDecimal - 0.5) * 10.0
  }

  private var aboveOutdoorTemp: Double {
    let evenDecimal = floor(outdoorDesignTemperature / 10)
    return (evenDecimal + 0.5) * 10.0
  }
}

extension FieldsetStyle {
  static var twoWayFormStyle: Self {
    .custom(.class("border-base-300 rounded-box border p-4"))
  }
}
