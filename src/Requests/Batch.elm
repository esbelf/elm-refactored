module Requests.Batch exposing (getAll)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, optional)
-- import Json.Encode as Encode
import Task exposing (Task)

import Models.Batch exposing (Batch)
import Requests.Base exposing (..)

getAll : String -> Task Http.Error (List Batch)
getAll token =
  Http.request
    { headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
    , body = Http.emptyBody
    , expect = Http.expectJson batchesDecoder
    , method = "GET"
    , timeout = Nothing
    , url = batchesUrl
    , withCredentials = False
    } |> Http.toTask

batchesDecoder : Decode.Decoder (List Batch)
batchesDecoder =
  Decode.list batchDecoder

batchDecoder : Decode.Decoder Batch
batchDecoder =
  decode Batch
    |> required "id" Decode.int
    |> required "group_id" Decode.int
    |> required "user_id" Decode.int
    |> optional "census_count" Decode.int 0
    |> optional "start_date" Decode.string ""
    |> optional "created_at" Decode.string ""

batchesUrl : String
batchesUrl =
  baseUrl ++ "/batches"
