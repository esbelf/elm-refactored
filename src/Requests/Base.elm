module Requests.Base exposing (RequestConfig, apiUrl, baseUrl, dataDecoder, getFileToken, maybeErrorDesc, stringToInt)

import Http exposing (Error(BadStatus))
import Json.Decode as Decode
import Task exposing (Task)


type alias RequestConfig model =
    { body : Http.Body
    , expect : Http.Expect model
    , headers : List Http.Header
    , method : String
    , timeout : Maybe Float
    , url : String
    , withCredentials : Bool
    }


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


dataDecoder : Decode.Decoder a -> Decode.Decoder a
dataDecoder innerDecoder =
    Decode.field "data" innerDecoder


stringToInt : String -> Decode.Decoder Int
stringToInt strNum =
    case String.toInt strNum of
        Ok num ->
            Decode.succeed num

        Err msg ->
            Decode.fail msg


fileTokenUrl : String
fileTokenUrl =
    apiUrl ++ "/file_authenticate"


apiUrl : String
apiUrl =
    baseUrl ++ "/api/v1"


baseUrl : String
baseUrl =
    "https://easyins-staging.herokuapp.com"



-- "http://localhost:3000"


maybeErrorDesc : Http.Error -> Maybe String
maybeErrorDesc error =
    case error of
        BadStatus response ->
            case Decode.decodeString messageDecoder response.body of
                Ok message ->
                    Just message

                Err _ ->
                    Nothing

        _ ->
            Nothing



-- Error decoding


type alias Message =
    { message : String
    }


messageDecoder : Decode.Decoder String
messageDecoder =
    Decode.field "message" Decode.string



--if String.contains Navigation.Location.host "localhost" then
--    "http://localhost:3000/api/v1"
--else
--    "https://easyins-staging.herokuapp.com/api/v1"
