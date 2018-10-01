module Requests.Group exposing (getAll, get, update, delete, previewUrl)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, optional)
import Json.Encode as Encode
import Task exposing (Task)

import Models.Group exposing (Group)
import Requests.Base exposing (..)

getAll : String -> Task Http.Error (List Group)
getAll token =
  Http.request
    { headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
    , body = Http.emptyBody
    , expect = Http.expectJson groupsDecoder
    , method = "GET"
    , timeout = Nothing
    , url = groupsUrl
    , withCredentials = False
    } |> Http.toTask

get : Int -> String -> Task Http.Error Group
get groupId token =
  Http.request
    { headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
    , body = Http.emptyBody
    , expect = Http.expectJson groupDecoder
    , method = "GET"
    , timeout = Nothing
    , url = groupUrl groupId
    , withCredentials = False
    } |> Http.toTask

update : Group -> String -> Task Http.Error Group
update group token =
  Http.request
    { headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
    , body = groupEncoder group
    , expect = Http.expectJson groupDecoder
    , method = "PATCH"
    , timeout = Nothing
    , url = groupUrl group.id
    , withCredentials = False
    } |> Http.toTask


delete : Int -> String -> Task Http.Error String
delete groupId token =
  Http.request
    { headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
    , expect = Http.expectString
    , body = Http.emptyBody
    , method = "DELETE"
    , timeout = Nothing
    , url = groupUrl groupId
    , withCredentials = False
    } |> Http.toTask

previewUrl : Int -> String -> String
previewUrl groupId fileToken =
  (groupUrl groupId) ++ "/preview?file_token=" ++ fileToken

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
