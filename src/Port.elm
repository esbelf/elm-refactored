port module Port exposing (FilePortData, Model, blank, fileContentRead, fileSelected, getStorage, openWindow, removeStorage, setStorage)

import Json.Encode as Encode



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


type alias FilePortData =
    { contents : String
    , filename : String
    }


port fileSelected : String -> Cmd msg


port fileContentRead : (FilePortData -> msg) -> Sub msg
