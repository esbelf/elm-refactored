module Main exposing(main)

import Model exposing (..)
import Update
import View
import Msg exposing (Msg)
import Navigation
import Route exposing (routeToPage, parseLocation)


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
  let
    currentPage =
      Route.routeToPage <| Route.parseLocation location
    -- get session from local storage and then pass here
    blankSession = ""
  in
    Model.init currentPage blankSession

main : Program Never Model Msg
main =
    Navigation.program Msg.NewLocation
        { init = init
        , view = View.view
        , update = Update.update
        , subscriptions = \_ -> Sub.none
        }