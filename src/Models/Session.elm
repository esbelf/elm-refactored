module Models.Session exposing (Session, checkSessionValidity, init, initWithRecord, toPortModel)

import Models.Storage as StorageModel exposing (StorageModel)
import String.Extra exposing (nonEmpty)
import Time exposing (Posix)


type alias Session =
    { token : String
    , exp : Posix
    }


{-| Take a token and expiry string, returning Nothing if either:

  - token string is empty
  - exp string is empty or unable to be parsed from ISO8601 format

-}
init : String -> Int -> Maybe Session
init token expMillis =
    let
        parsedExp =
            Time.millisToPosix expMillis
                |> Result.toMaybe
    in
    Maybe.map2 Session (nonEmpty token) parsedExp


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
