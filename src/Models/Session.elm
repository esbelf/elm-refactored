module Models.Session exposing (Session, init, initWithRecord, toPortModel, valid)

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
