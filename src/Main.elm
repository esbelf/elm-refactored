module Main exposing (main)

import Browser
import Browser.Navigation as Navigation
import Model exposing (..)
import Models.Session
import Models.Storage exposing (StorageModel)
import Msg exposing (..)
import Route
import Subscription
import Time
import Update
import Url exposing (Url)
import View


type alias Flags =
    { state : Maybe StorageModel
    , now : Int
    }


init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        currentRoute =
            Route.fromUrl url

        session =
            Models.Session.initWithRecord flags.state
    in
    Route.setRoute currentRoute (Model.init session flags.now navKey)


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
    Browser.application
        { init = init
        , view = View.view
        , update = Update.update
        , subscriptions = subscriptions
        , onUrlRequest = ClickedLink
        , onUrlChange = RouteChanged << Route.fromUrl
        }
