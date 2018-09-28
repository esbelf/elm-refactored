module Helper exposing (..)

import Msg exposing (..)
import Model exposing (PageState(..), Model)
import Page

pageErrored : Model -> ( Model, Cmd Msg )
pageErrored model =
  let
    errorMsg = "Not authorized to view page"
  in
    ({ model | pageState = Loaded (Page.Error errorMsg) }, Cmd.none)
