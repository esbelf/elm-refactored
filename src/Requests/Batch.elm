module Requests.Batch exposing (getAll, formUrl)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, optional, requiredAt, optionalAt, custom)
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

formUrl : Int -> String -> String
formUrl batchId fileToken =
  batchesUrl ++ "/" ++ (toString batchId) ++ "/download?file_token=" ++ fileToken

batchesDecoder : Decode.Decoder (List Batch)
batchesDecoder =
  Decode.field "data" (Decode.list batchDecoder)

batchDecoder : Decode.Decoder Batch
batchDecoder =
  decode Batch
    |> custom ((Decode.at [ "id" ] Decode.string) |> Decode.andThen stringToInt )
    |> requiredAt [ "attributes", "group_id" ] Decode.int
    |> optionalAt [ "attributes", "group_name" ] Decode.string ""
    |> requiredAt [ "attributes", "user_id" ] Decode.int
    |> optionalAt [ "attributes", "user_email" ] Decode.string ""
    |> optionalAt [ "attributes", "census_count"] Decode.int 0
    |> optionalAt [ "attributes", "start_date" ] Decode.string ""
    |> optionalAt [ "attributes", "created_at" ] Decode.string ""

batchesUrl : String
batchesUrl =
  baseUrl ++ "/batches"
