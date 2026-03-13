import Elementary
import ElementaryHTMX
import ManualSRouter
import SharedModels

struct Navbar: HTML, Sendable {
  let userID: User.ID

  var body: some HTML<HTMLTag.div> {
    div(.class("navbar bg-base-200 border-accent border-b shadow-sm p-4")) {
      div(.class("flex-1 ms-6")) {
        h1(.class("text-4xl")) { "Manual-S" }
      }
      div(.class("flex-none")) {
        a(
          .class("btn btn-ghost"),
          .href(route: ManualSRoute.shared(.project(.index)))
        ) {
          "Projects"
        }
        a(
          .class("btn btn-ghost"),
          .href(route: ManualSRoute.shared(.user(.profile(userID, .index))))
        ) {
          "Profile"
        }
      }
    }
  }
}
