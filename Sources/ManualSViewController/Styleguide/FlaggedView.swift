import Elementary
import SharedStyleguide

enum FlaggedState: String {
  case success
  case error
}

struct FlaggedView<Content: HTML>: HTML {

  let state: FlaggedState
  let _content: Content

  init(_ state: FlaggedState, @HTMLBuilder content: () -> Content) {
    self.state = state
    self._content = content()
  }

  var body: some HTML<HTMLTag.div> {
    div(.class("flex text-\(state.rawValue) gap-2")) {
      _content
      div(.class("rotate-45 mt-1")) {
        SVG(.flag)
      }
    }
  }
}
