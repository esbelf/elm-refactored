module Requests.Batch exposing (getAll)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, optional)
import Task exposing (Task)

import Models.Batch exposing (Batch)
import Requests.Base exposing (..)
import Requests.Group

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
    }
  |> Http.toTask
  |> Task.map (iterateOverBatch token)

iterateOverBatch : String -> List Batch -> Task Http.Error (List Batch)
iterateOverBatch token batches =
  List.map (getGroup token) batches

  --Task.succeed
  --  <| List.map (getGroup token) batches


  --case batches of
  --  Just batches ->
  --    Task.succeed batches
  --  Nothing ->
  --    Task.fail "No Batches"

getGroup : String -> Batch -> Task Http.Error Group
getGroup token batch =
  let
    groupId = batch.group_id
  in
    Requests.Group.get groupId token



  --case batch
  --  batch.group_id
  --let
  --  groupId = batch.group_id
  --  --request Requests.Group.get groupId token
  --in


---------------------
---------------------

--getAll : String -> Task Http.Error (List Batch)
--getAll token =
--  Http.request
--    { headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
--    , body = Http.emptyBody
--    , expect = Http.expectJson batchesDecoder
--    , method = "GET"
--    , timeout = Nothing
--    , url = batchesUrl
--    , withCredentials = False
--    }
--  |> Http.toTask


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
