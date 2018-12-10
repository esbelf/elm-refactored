module Requests.Batch exposing (create, formUrl, getAll)

-- import Json.Encode as Encode

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (custom, optional, optionalAt, required, requiredAt)
import Json.Encode as Encode
import Models.Batch exposing (Batch, BatchForm)
import Requests.Base exposing (..)
import Task exposing (Task)


getAll : String -> (Result Http.Error (List Batch) -> msg) -> Cmd msg
getAll token callback =
    Http.request
        { headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , body = Http.emptyBody
        , expect = Http.expectJson callback (dataDecoder batchesDecoder)
        , method = "GET"
        , timeout = Nothing
        , url = batchesUrl
        , tracker = Nothing
        }


create : BatchForm -> String -> (Result Http.Error () -> msg) -> Cmd msg
create batchForm token callback =
    Http.request
        { headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , body = batchEncoder batchForm
        , expect = Http.expectWhatever callback
        , method = "POST"
        , timeout = Nothing
        , url = batchesUrl
        , tracker = Nothing
        }


batchEncoder : BatchForm -> Http.Body
batchEncoder batch =
    let
        attributes =
            [ ( "file_name", Encode.string batch.fileName )
            , ( "start_date", Encode.string batch.startDate )
            , ( "census_file", Encode.string batch.fileData )
            , ( "group_id", Encode.int batch.groupId )
            ]
    in
    Encode.object attributes
        |> Http.jsonBody


formUrl : Int -> String -> String
formUrl batchId fileToken =
    batchesUrl ++ "/" ++ String.fromInt batchId ++ "/download?file_token=" ++ fileToken


batchesDecoder : Decode.Decoder (List Batch)
batchesDecoder =
    Decode.list batchDecoder


batchDecoder : Decode.Decoder Batch
batchDecoder =
    Decode.succeed Batch
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
    apiUrl ++ "/batches"
