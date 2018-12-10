module Requests.User exposing (delete, fetch, urlSlug, userDecoder, userUrl, usersDecoder)

-- import Json.Encode as Encode

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (custom, optional, optionalAt, required, requiredAt)
import Models.User exposing (User)
import Requests.Base exposing (..)
import Task exposing (Task)


fetch : String -> (Result Http.Error (List User) -> msg) -> Cmd msg
fetch token callback =
    Http.request
        { body = Http.emptyBody
        , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , expect = Http.expectJson callback (dataDecoder usersDecoder)
        , method = "GET"
        , timeout = Nothing
        , url = userUrl
        , tracker = Nothing
        }


delete : Int -> String -> (Result Http.Error () -> msg) -> Cmd msg
delete userId token callback =
    Http.request
        { headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , expect = Http.expectWhatever callback
        , body = Http.emptyBody
        , method = "DELETE"
        , timeout = Nothing
        , url = urlSlug userId
        , tracker = Nothing
        }


usersDecoder : Decode.Decoder (List User)
usersDecoder =
    Decode.list userDecoder


userDecoder : Decode.Decoder User
userDecoder =
    Decode.succeed User
        |> custom (Decode.at [ "id" ] Decode.string |> Decode.andThen stringToInt)
        |> requiredAt [ "attributes", "email" ] Decode.string



--encode : User -> Encode.Value
--encode user =
--  let
--    attributes =
--      [ ( "id", Encode.int user.id )
--      , ( "email", Encode.string user.email)
--      ]
--  in
--    Encode.object attributes


urlSlug : Int -> String
urlSlug userId =
    userUrl ++ "/" ++ String.fromInt userId


userUrl : String
userUrl =
    apiUrl ++ "/users"
