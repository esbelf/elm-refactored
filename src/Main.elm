module Main exposing(main)

import Model exposing (..)
import Update
import View
import Msg exposing (..)
import Navigation
import Route exposing (setRoute, parseLocation, urlChange)


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
  let
    currentRoute = Route.parseLocation location
    -- get session from local storage and then pass here
    blankSession = ""
  in
    Route.setRoute currentRoute (Model.init blankSession)

main : Program Never Model Msg
main =
  Navigation.program Route.urlChange
    { init = init
    , view = View.view
    , update = Update.update
    , subscriptions = \_ -> Sub.none
    }