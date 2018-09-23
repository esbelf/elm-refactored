module Requests.Auth exposing (..)

import Http
import Json.Decode as Decode
-- import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Task exposing (Task)

import Requests.Base exposing (..)

type alias AuthObj =
  { email : String
  , password : String
  }

authenticate : AuthObj -> Task Http.Error String
authenticate authObj =
  let
    body = authObj |> encode |> Http.jsonBody
  in
    (Http.post authUrl body tokenDecoder) |> Http.toTask


tokenDecoder : Decode.Decoder String
tokenDecoder =
  Decode.field "token" Decode.string

encode : AuthObj -> Encode.Value
encode model =
  Encode.object
    [ ("email", Encode.string model.email)
    , ("password", Encode.string model.password)
    ]

authUrl : String
authUrl =
  baseUrl ++ "/authenticate"
