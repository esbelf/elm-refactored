module Main exposing(main)

import Model exposing (..)
import Update
import View
import Msg exposing (Msg)
import Html

main : Program Never Model Msg
main =
    Html.program
        { init = Model.init
        , view = View.view
        , update = Update.update
        , subscriptions = \_ -> Sub.none
        }