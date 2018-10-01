port module Port exposing (..)

import Json.Encode as Encode
--import Msg exposing (..)

type alias Model =
  { session : String }

init : Model
init =
  { session = "" }

port setStorage : Model -> Cmd msg

port removeStorage : () -> Cmd msg

port getStorage : Encode.Value -> Cmd msg

port openWindow : String -> Cmd msg
