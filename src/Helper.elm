module Helper exposing (pageErrored)

import Model exposing (Model, PageState(..))
import Msg exposing (..)
import Page


pageErrored : Model -> ( Model, Cmd Msg )
pageErrored model =
    let
        errorMsg =
            "Not authorized to view page"
    in
    ( { model | pageState = Loaded (Page.Error errorMsg) }, Cmd.none )
