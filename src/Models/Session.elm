module Models.Session exposing (Session, init, initWithRecord, toPortModel, valid)

-- import Models.User exposing (User)
--import Debug

import Port
import String.Extra exposing (nonEmpty)
import Time.DateTime as DateTime exposing (DateTime)
import Time.Iso8601 exposing (fromDateTime, toDateTime)


type alias Session =
    { token : String
    , exp : DateTime
    }


{-| Take a token and expiry string, returning Nothing if either:

  - token string is empty
  - exp string is empty or unable to be parsed from ISO8601 format

-}
init : String -> String -> Maybe Session
init token exp =
    let
        parsedExp =
            toDateTime exp
                |> Result.toMaybe
    in
    Maybe.map2 Session (nonEmpty token) parsedExp


initWithRecord : Maybe { token : String, exp : String } -> Maybe Session
initWithRecord maybeRec =
    case maybeRec of
        Just record ->
            init record.token record.exp

        Nothing ->
            Nothing


validateSession : Session -> DateTime -> Bool
validateSession session now =
    case DateTime.compare session.exp now of
        LT ->
            True

        _ ->
            False


valid : Maybe Session -> DateTime -> Bool
valid maybeSession now =
    case maybeSession of
        Just session ->
            validateSession session now

        Nothing ->
            False


toPortModel : Maybe Session -> Port.Model
toPortModel maybeSession =
    let
        sessionToPort session =
            { token = session.token
            , exp = fromDateTime session.exp
            }
    in
    Maybe.map sessionToPort maybeSession
        |> Maybe.withDefault Port.init



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
