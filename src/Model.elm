module Model exposing (Model, init)

import Page exposing (Page)
import Msg exposing (Msg)

type PageState
    = Loaded Page
    | TransitioningFrom Page

type alias Model =
  { session : String
  , pageState : PageState
  }

init : Page -> String -> ( Model, Cmd Msg )
init page session =
  ({ pageState = Loaded page
  , session = session
  }, Cmd.none)

