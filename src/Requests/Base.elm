module Requests.Base exposing (baseUrl, getFileToken)

import Http
import Json.Decode as Decode
import Task exposing (Task)

getFileToken : String -> Task Http.Error String
getFileToken token =
  Http.request
    { headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
    , body = Http.emptyBody
    , expect = Http.expectJson fileTokenDecoder
    , method = "POST"
    , timeout = Nothing
    , url = fileTokenUrl
    , withCredentials = False
    }
    |> Http.toTask

fileTokenDecoder : Decode.Decoder String
fileTokenDecoder =
  Decode.field "token" Decode.string

fileTokenUrl : String
fileTokenUrl =
  baseUrl ++ "/file_authenticate"

baseUrl : String
baseUrl =
  "http://localhost:3000/api/v1"
