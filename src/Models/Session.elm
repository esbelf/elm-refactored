module Models.Session exposing (Session, init, valid)

-- import Models.User exposing (User)
--import Debug
--import Time.DateTime as DateTime exposing (DateTime, fromTimestamp)
--import Time.Date exposing (Date)
--import Json.Decode exposing (Decoder, string, andThen, succeed, fail)
--import Json.Decode.Extra exposing (fromResult)
--import ISO8601
--import Time.DateTime as DateTime exposing(DateTime)
--import Time exposing (..)
--import Task exposing (Task)

import Port


type alias Session =
    { token : String
    , exp : String
    }


init : String -> String -> Session
init token exp =
    if String.isEmpty token then
        { token = ""
        , exp = ""
        }

    else
        { token = token
        , exp = exp
        }


valid : Session -> Bool
valid session =
    let
        token =
            session.token
    in
    if String.isEmpty token then
        False

    else
        True



--case Port.expired of
--  Ok result ->
--    True
--  Err _ ->
--    False
--expTimestamp = ISO8601.fromString session.exp
--currentTimestamp = Task.attempt processTime Time.now
--result = compare expTimestamp currentTimestamp
---- log = Debug.log "Valid timestamp" timestamp
--processTime : Result String Time.Time -> Time.Time
--processTime result =
--  case result of
--    Ok time ->
--      time
--    Err _ ->
--      millisToPosix 0
--currentTimestamp =
--  case Time.now of
--    Ok res ->
--      res
--    Err err ->
--      0
--convertTimestamp : Decoder Date
--convertTimestamp =
--  string |> andThen (Time.Date.fromString >> fromResult)
--  2018-10-04T23:27:18.958Z
--type alias Session =
--  { user : Maybe User
--  , token : String
--  }
--attempt : String -> (AuthToken -> Cmd msg) -> Session -> ( List String, Cmd msg )
--attempt attemptedAction toCmd session =
--    case Maybe.map .token session.user of
--        Nothing ->
--            [ "You have been signed out. Please sign back in to " ++ attemptedAction ++ "." ] => Cmd.none
--        Just token ->
--            [] => toCmd token
