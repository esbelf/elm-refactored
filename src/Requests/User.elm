module Requests.User exposing (delete, fetch, urlSlug, userDecoder, userUrl, usersDecoder)

-- import Json.Encode as Encode

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (custom, optional, optionalAt, required, requiredAt)
import Models.User exposing (User)
import Requests.Base exposing (..)
import Task exposing (Task)


fetch : String -> Task Http.Error (List User)
fetch token =
    Http.request
        { body = Http.emptyBody
        , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , expect = Http.expectJson (dataDecoder usersDecoder)
        , method = "GET"
        , timeout = Nothing
        , url = userUrl
        , withCredentials = False
        }
        |> Http.toTask


delete : Int -> String -> Task Http.Error String
delete userId token =
    Http.request
        { headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , expect = Http.expectString
        , body = Http.emptyBody
        , method = "DELETE"
        , timeout = Nothing
        , url = urlSlug userId
        , withCredentials = False
        }
        |> Http.toTask


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
