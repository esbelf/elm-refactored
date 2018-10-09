module Models.Session exposing (Session, init, valid)


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
