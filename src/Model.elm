module Model exposing (Model, init)

import Page exposing (Page, initialPage)
import Msg exposing (Msg)

type alias Model =
  { currentPage : Page
  , session : String
  }

init : ( Model, Cmd Msg )
init =
  ({ currentPage = initialPage
  , session = ""
  }, Cmd.none)

