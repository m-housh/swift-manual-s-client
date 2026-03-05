import Dependencies
import Elementary
import Foundation

struct HomePage: HTML {

  var body: some HTML {
    div(.class("px-10")) {
      h1(.class("text-3xl")) { "Fix Me!" }

      div(.class("w-[50%]")) {
        DesignInfoForm(projectID: .init(UUID(0)), designInfo: nil)
      }

      div(.class("w-[50%]")) {
        CoolingSystemTypeForm(systemType: nil)
      }
    }
  }
}
