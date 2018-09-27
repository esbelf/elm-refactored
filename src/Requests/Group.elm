module Requests.Group exposing (getAll, get, update, delete)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, optional)
import Json.Encode as Encode
import Task exposing (Task)

import Models.Group exposing (Group)
import Requests.Base exposing (..)

getAll : Task Http.Error (List Group)
getAll =
  Http.get groupsUrl groupsDecoder
    |> Http.toTask

get : Int -> Task Http.Error Group
get groupId =
  Http.get (groupUrl groupId) groupDecoder
    |> Http.toTask

update : Group -> Task Http.Error Group
update group =
  Http.request
    { headers = []
    , body = groupEncoder group
    , expect = Http.expectJson groupDecoder
    , method = "PATCH"
    , timeout = Nothing
    , url = groupUrl group.id
    , withCredentials = False
    } |> Http.toTask


delete : Int -> Task Http.Error String
delete groupId =
  Http.request
    { headers = []
    , expect = Http.expectString
    , body = Http.emptyBody
    , method = "DELETE"
    , timeout = Nothing
    , url = groupUrl groupId
    , withCredentials = False
    } |> Http.toTask

groupEncoder : Group -> Http.Body
groupEncoder group =
  let
    attributes =
      [ ( "id", Encode.int group.id )
      , ( "name", Encode.string group.name )
      , ( "disclosure", Encode.string group.disclosure )
      , ( "form_type", Encode.string group.form_type )
      , ( "payment_mode", Encode.int group.payment_mode )
      ]
  in
    Encode.object attributes
      |> Http.jsonBody

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

groupUrl : Int -> String
groupUrl groupId =
  groupsUrl ++ "/" ++ (toString groupId)

groupsUrl : String
groupsUrl =
  baseUrl ++ "/groups"
