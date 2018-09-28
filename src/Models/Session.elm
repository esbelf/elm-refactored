module Models.Session exposing (Session, init, valid)

-- import Models.User exposing (User)

type alias Session =
  { token : Maybe String }

init : String -> Session
init token =
    if (String.isEmpty token) then
      { token = Nothing }
    else
      { token = Just token }

valid : Session -> Bool
valid session =
  let
    maybeToken = session.token
  in
    case maybeToken of
      Just maybeToken ->
        True
      Nothing ->
        False


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
