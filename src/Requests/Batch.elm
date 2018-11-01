module Requests.Batch exposing (create, formUrl, getAll)

-- import Json.Encode as Encode

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (custom, decode, optional, optionalAt, required, requiredAt)
import Json.Encode as Encode
import Models.Batch exposing (Batch)
import Port
import Requests.Base exposing (..)
import Task exposing (Task)


getAll : String -> Task Http.Error (List Batch)
getAll token =
    Http.request
        { headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , body = Http.emptyBody
        , expect = Http.expectJson (dataDecoder batchesDecoder)
        , method = "GET"
        , timeout = Nothing
        , url = batchesUrl
        , withCredentials = False
        }
        |> Http.toTask


create : Port.FilePortData -> String -> Task Http.Error String
create file token =
    Http.request
        { headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , body = fileEncoder file
        , expect = Http.expectString
        , method = "POST"
        , timeout = Nothing
        , url = batchesUrl
        , withCredentials = False
        }
        |> Http.toTask


fileEncoder : Port.FilePortData -> Http.Body
fileEncoder file =
    let
        attributes =
            [ ( "name", Encode.string file.filename )
            , ( "contents", Encode.string file.contents )
            ]
    in
    Encode.object attributes
        |> Http.jsonBody


formUrl : Int -> String -> String
formUrl batchId fileToken =
    batchesUrl ++ "/" ++ toString batchId ++ "/download?file_token=" ++ fileToken


batchesDecoder : Decode.Decoder (List Batch)
batchesDecoder =
    Decode.list batchDecoder


batchDecoder : Decode.Decoder Batch
batchDecoder =
    decode Batch
        |> custom (Decode.at [ "id" ] Decode.string |> Decode.andThen stringToInt)
        |> requiredAt [ "attributes", "group_id" ] Decode.int
        |> optionalAt [ "attributes", "group_name" ] Decode.string ""
        |> requiredAt [ "attributes", "user_id" ] Decode.int
        |> optionalAt [ "attributes", "user_email" ] Decode.string ""
        |> optionalAt [ "attributes", "census_count" ] Decode.int 0
        |> optionalAt [ "attributes", "start_date" ] Decode.string ""
        |> optionalAt [ "attributes", "created_at" ] Decode.string ""


batchesUrl : String
batchesUrl =
    baseUrl ++ "/batches"
