module Pages.Login exposing (..)

type Msg
  = SetUsername String
  | SetPassword String

type alias Model =
  { username : String
  , password : String
  }

update : Msg -> Model -> Model
update msg model =
  case msg of
    SetUsername username ->
      { model | username = username }
    SetPassword password ->
      { model | password = password }
