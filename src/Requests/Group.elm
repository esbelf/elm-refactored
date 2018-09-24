module Requests.Group exposing (..)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, optional)
import Task exposing (Task)

import Models.Group exposing (Group)
import Requests.Base exposing (..)

fetch : Task Http.Error (List Group)
fetch =
  Http.get groupUrl groupsDecoder
    |> Http.toTask

delete : Int -> Task Http.Error String
delete groupId =
  Http.request
    { headers = []
    , expect = Http.expectString
    , body = Http.emptyBody
    , method = "DELETE"
    , timeout = Nothing
    , url = urlSlug groupId
    , withCredentials = False
    } |> Http.toTask

groupsDecoder : Decode.Decoder (List Group)
groupsDecoder =
  Decode.list groupDecoder


groupDecoder : Decode.Decoder Group
groupDecoder =
  decode Group
    |> required "id" Decode.int
    |> required "name" Decode.string
    |> optional "disclosure" Decode.string ""
    |> optional "form_type" Decode.string ""
    |> optional "payment_mode" Decode.int 12

urlSlug : Int -> String
urlSlug groupId =
  groupUrl ++ "/" ++ (toString groupId)

groupUrl : String
groupUrl =
  baseUrl ++ "/groups"
