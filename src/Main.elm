module Main exposing(main)

import Model exposing (..)
import Update
import View
import Msg exposing (..)
import Navigation
import Route exposing (setRoute, parseLocation, urlChange)
import Port
import Debug

init : Maybe Port.Model -> Navigation.Location -> ( Model, Cmd Msg )
init flags location =
  let
    currentRoute =
      Route.parseLocation location
    ports =
      case flags of
        Just portModel ->
          portModel
        Nothing ->
          Port.init
    log1 = Debug.log "token" ports.token
    log2 = Debug.log "exp" ports.exp
  in
    Route.setRoute currentRoute (Model.init ports)

main : Program (Maybe Port.Model) Model Msg
main =
  Navigation.programWithFlags Route.urlChange
    { init = init
    , view = View.view
    , update = Update.update
    , subscriptions = \_ -> Sub.none
    }