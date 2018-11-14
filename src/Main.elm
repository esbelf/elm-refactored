module Main exposing (main)

import Model exposing (..)
import Models.Session
import Msg exposing (..)
import Navigation
import Port
import Route exposing (parseLocation, setRoute, urlChange)
import Subscription
import Time exposing (minute)
import Update
import View


type alias Flags =
    { state : Maybe Port.Model
    , now : Float
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
