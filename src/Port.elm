port module Port exposing (..)

import Json.Encode as Encode

type alias Model =
  { session : String }

init : Model
init =
  { session = "" }

port setStorage : Model -> Cmd msg

port removeStorage : Model -> Cmd msg

port getStorage : Encode.Value -> Cmd msg
