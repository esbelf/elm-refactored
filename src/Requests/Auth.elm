module Requests.Auth exposing (..)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Task exposing (Task)

import Requests.Base exposing (..)
import Models.Session exposing (Session)

type alias AuthObj =
  { email : String
  , password : String
  }

authenticate : AuthObj -> Task Http.Error Session
authenticate authObj =
  let
    body = authObj |> encode |> Http.jsonBody
  in
    (Http.post authUrl body sessionDecoder) |> Http.toTask

sessionDecoder : Decode.Decoder Session
sessionDecoder =
  decode Session
    |> required "token" Decode.string
    |> required "exp" Decode.string


encode : AuthObj -> Encode.Value
encode model =
  Encode.object
    [ ("email", Encode.string model.email)
    , ("password", Encode.string model.password)
    ]

authUrl : String
authUrl =
  baseUrl ++ "/authenticate"
