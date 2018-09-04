module Model exposing (Model, init)

import Page exposing (Page)
import Msg exposing (Msg)

type alias Model =
  { currentPage : Page
  , session : String
  }

init : Page -> String -> ( Model, Cmd Msg )
init page session =
  ({ currentPage = page
  , session = session
  }, Cmd.none)

