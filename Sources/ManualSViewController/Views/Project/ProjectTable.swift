import Elementary
import SharedModels
import SharedStyleguide
import SharedViews

struct ProjectTable: HTML, Sendable {
  let project: Project

  var body: some HTML<HTMLTag.table> {
    table(.class("table table-zebra text-lg")) {
      tbody {
        tr {
          td(.class("label")) { "Name" }
          td { project.name }
        }
        tr {
          td(.class("label")) { "Street Address" }
          td { project.streetAddress }
        }
        tr {
          td(.class("label")) { "City" }
          td { project.city }
        }
        tr {
          td(.class("label")) { "State" }
          td { project.state }
        }
        tr {
          td(.class("label")) { "Zip" }
          td { project.zipCode }
        }
      }
    }
  }
}
