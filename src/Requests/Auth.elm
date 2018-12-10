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


authenticate : AuthObj -> (Result Http.Error Session -> msg) -> Cmd msg
authenticate authObj callback =
    let
        body =
            authObj |> encode |> Http.jsonBody
    in
    Http.post
        { url = authUrl
        , body = body
        , expect = Http.expectJson callback sessionDecoder
        }


sessionDecoder : Decode.Decoder Session
sessionDecoder =
    Decode.succeed Session
        |> required "exp" Iso8601.decoder
        |> required "token" Decode.string


encode : AuthObj -> Encode.Value
encode model =
    Encode.object
        [ ( "email", Encode.string model.email )
        , ( "password", Encode.string model.password )
        ]


authUrl : String
authUrl =
    apiUrl ++ "/authenticate"
