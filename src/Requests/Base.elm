module Requests.Base exposing (RequestConfig, apiUrl, baseUrl, dataDecoder, getFileToken, maybeErrorDesc, stringToInt)

import Http exposing (Error(..))
import Json.Decode as Decode
import Task exposing (Task)


type alias RequestConfig msg =
    { method : String
    , headers : List Http.Header
    , url : String
    , body : Http.Body
    , expect : Http.Expect msg
    , timeout : Maybe Float
    , tracker : Maybe String
    }


getFileToken : String -> (Result Http.Error String -> msg) -> Cmd msg
getFileToken token callback =
    Http.request
        { method = "POST"
        , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , url = fileTokenUrl
        , body = Http.emptyBody
        , expect = Http.expectJson callback fileTokenDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


fileTokenDecoder : Decode.Decoder String
fileTokenDecoder =
    Decode.field "token" Decode.string


dataDecoder : Decode.Decoder a -> Decode.Decoder a
dataDecoder innerDecoder =
    Decode.field "data" innerDecoder


stringToInt : String -> Decode.Decoder Int
stringToInt strNum =
    case String.toInt strNum of
        Just num ->
            Decode.succeed num

        Nothing ->
            Decode.fail ("Could not parse '" ++ strNum ++ "' into Integer.")


fileTokenUrl : String
fileTokenUrl =
    apiUrl ++ "/file_authenticate"


apiUrl : String
apiUrl =
    baseUrl ++ "/api/v1"


baseUrl : String
baseUrl =
    "https://easyins-staging.herokuapp.com"



-- "https://easyins-staging.herokuapp.com"
-- "http://localhost:3000"


maybeErrorDesc : Http.Error -> Maybe String
maybeErrorDesc error =
    case error of
        BadStatus code ->
            Just <| "Got an Error response code: " ++ String.fromInt code

        BadBody body ->
            Just ("Error parsing body: " ++ body)

        _ ->
            Nothing



--if String.contains Navigation.Location.host "localhost" then
--    "http://localhost:3000/api/v1"
--else
--    "https://easyins-staging.herokuapp.com/api/v1"
