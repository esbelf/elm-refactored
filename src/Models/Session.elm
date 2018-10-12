module Models.Session exposing (Session, checkSessionValidity, init, initWithRecord, toPortModel)

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


{-| Remove sessions that are invalid -- currently, only check is time expiry
-}
checkSessionValidity : Maybe Session -> DateTime -> Maybe Session
checkSessionValidity maybeSession now =
    Maybe.andThen (sessionExpiredCheck now) maybeSession


{-| -}
sessionExpiredCheck : DateTime -> Session -> Maybe Session
sessionExpiredCheck now session =
    case DateTime.compare session.exp now of
        LT ->
            Just session

        _ ->
            Nothing


toPortModel : Maybe Session -> Port.Model
toPortModel maybeSession =
    let
        sessionToPort session =
            { token = session.token
            , exp = fromDateTime session.exp
            }
    in
    Maybe.map sessionToPort maybeSession
        |> Maybe.withDefault Port.blank
