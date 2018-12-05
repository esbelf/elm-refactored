module Requests.Auth exposing (AuthObj, authUrl, authenticate, encode, sessionDecoder)

import Http
import Iso8601
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode
import Models.Session exposing (Session)
import Requests.Base exposing (..)
import Task exposing (Task)


type alias AuthObj =
    { email : String
    , password : String
    }


authenticate : AuthObj -> Task Http.Error Session
authenticate authObj =
    let
        body =
            authObj |> encode |> Http.jsonBody
    in
    Http.post authUrl body sessionDecoder |> Http.toTask


sessionDecoder : Decode.Decoder Session
sessionDecoder =
    Decode.succeed Session
        |> required "token" Decode.string
        |> required "exp" Iso8601.decoder


encode : AuthObj -> Encode.Value
encode model =
    Encode.object
        [ ( "email", Encode.string model.email )
        , ( "password", Encode.string model.password )
        ]


authUrl : String
authUrl =
    apiUrl ++ "/authenticate"
