port module Port exposing (..)

import Json.Encode as Encode
--import Msg exposing (..)

type alias Model =
  { token : String
  , exp : String
  }

init : Model
init =
  { token = ""
  , exp = ""
  }

port setStorage : Model -> Cmd msg

port removeStorage : () -> Cmd msg

port getStorage : Encode.Value -> Cmd msg

port openWindow : String -> Cmd msg

-- port expired : String -> Cmd msg