module Models.Session exposing (Session, checkSessionValidity, init, initWithRecord, toStorageModel)

import Models.Storage as StorageModel exposing (StorageModel)
import String.Extra
import Time exposing (Posix)


type alias Session =
    { exp : Posix
    , token : String
    }


{-| Take a token and expiry in milliseconds, returning Nothing if either:

  - token string is empty
  - exp string is empty or unable to be parsed from ISO8601 format

-}
init : String -> Int -> Maybe Session
init token expMillis =
    let
        expPosix =
            Time.millisToPosix expMillis

        maybeToken =
            String.Extra.nonBlank token
    in
    Maybe.map (Session expPosix) maybeToken


initWithRecord : Maybe StorageModel -> Maybe Session
initWithRecord maybeRec =
    case maybeRec of
        Just record ->
            init record.token record.exp

        Nothing ->
            Nothing


{-| Remove sessions that are invalid -- currently, only check is time expiry
-}
checkSessionValidity : Maybe Session -> Posix -> Maybe Session
checkSessionValidity maybeSession now =
    Maybe.andThen (sessionExpiredCheck now) maybeSession


{-| -}
sessionExpiredCheck : Posix -> Session -> Maybe Session
sessionExpiredCheck now session =
    case Time.posixToMillis now < Time.posixToMillis session.exp of
        True ->
            Just session

        False ->
            Nothing


toStorageModel : Session -> StorageModel
toStorageModel session =
    { token = session.token
    , exp = Time.posixToMillis session.exp
    }
