module Main exposing (main)

import Debug
import Model exposing (..)
import Msg exposing (..)
import Navigation
import Port
import Route exposing (parseLocation, setRoute, urlChange)
import Update
import View


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

        log1 =
            Debug.log "token" ports.token

        log2 =
            Debug.log "exp" ports.exp
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
