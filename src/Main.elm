module Main exposing(main)

import Models.Model as Model exposing (..)
import Updates.Update as Update
import Views.View as View

import Html

main : Program Never Model Msg
main =
    Html.program
        { init = Model.init
        , view = View.view
        , update = Update.update
        , subscriptions = \_ -> Sub.none
        }