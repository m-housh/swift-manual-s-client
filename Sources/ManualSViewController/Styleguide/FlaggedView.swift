import Elementary
import ManualSModels
import SharedStyleguide

struct FlaggedView<Content: HTML>: HTML {

  let state: FlaggedState
  let _content: Content

  init(_ state: FlaggedState, @HTMLBuilder content: () -> Content) {
    self.state = state
    self._content = content()
  }

  var body: some HTML<HTMLTag.div> {
    div(.class("flex text-\(state.color) gap-2")) {
      _content
      div(.class("rotate-45")) {
        SVG(.flag)
      }
    }
  }
}

extension FlaggedState {
  var color: String {
    switch self {
    case .success: return rawValue
    case .failure: return "error"
    }
  }
}
