port module Port exposing (Model, blank, fileContentRead, fileSelected, getStorage, openWindow, removeStorage, setStorage)

import Json.Encode as Encode
import Models.FileData exposing (FileData)



--import Msg exposing (..)


type alias Model =
    { token : String
    , exp : String
    }


{-| Blank port model -- encodes/decodes from model.session == Nothing
-}
blank : Model
blank =
    { token = ""
    , exp = ""
    }


port setStorage : Model -> Cmd msg


port removeStorage : () -> Cmd msg


port getStorage : Encode.Value -> Cmd msg


port openWindow : String -> Cmd msg



----- FILE UPLOAD --------


port fileSelected : String -> Cmd msg


port fileContentRead : (FileData -> msg) -> Sub msg
