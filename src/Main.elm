module Main exposing (main)

import Model exposing (..)
import Models.Session
import Models.Storage exposing (StorageModel)
import Msg exposing (..)
import Navigation
import Route exposing (parseLocation, setRoute, urlChange)
import Subscription
import Time
import Update
import View


type alias Flags =
    { state : Maybe StorageModel
    , now : Int
    }


init : Flags -> Navigation.Location -> ( Model, Cmd Msg )
init flags location =
    let
        currentRoute =
            Route.parseLocation location

        session =
            Models.Session.initWithRecord flags.state
    in
    Route.setRoute currentRoute (Model.init session flags.now)


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        minute =
            1000 * 60
    in
    Sub.batch
        [ Time.every minute TimeTick
        , Subscription.pageSubscriptions model
        ]


main : Program Flags Model Msg
main =
    Navigation.programWithFlags Route.urlChange
        { init = init
        , view = View.view
        , update = Update.update
        , subscriptions = subscriptions
        }
