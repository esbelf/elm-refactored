module Requests.User exposing (..)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
-- import Json.Encode as Encode
import Task exposing (Task)

import Models.User exposing (User)
import Requests.Base exposing (..)

fetch : Task Http.Error (List User)
fetch =
  Http.get userUrl usersDecoder
    |> Http.toTask

delete : Int -> Task Http.Error String
delete userId =
  Http.request
    { headers = []
    , expect = Http.expectString
    , body = Http.emptyBody
    , method = "DELETE"
    , timeout = Nothing
    , url = urlSlug userId
    , withCredentials = False
    } |> Http.toTask

usersDecoder : Decode.Decoder (List User)
usersDecoder =
  Decode.list userDecoder

userDecoder : Decode.Decoder User
userDecoder =
  decode User
    |> required "id" Decode.int
    |> required "email" Decode.string


--encode : User -> Encode.Value
--encode user =
--  let
--    attributes =
--      [ ( "id", Encode.int user.id )
--      , ( "email", Encode.string user.email)
--      ]
--  in
--    Encode.object attributes

urlSlug : Int -> String
urlSlug userId =
  userUrl ++ "/" ++ (toString userId)

userUrl : String
userUrl =
  baseUrl ++ "/users"

