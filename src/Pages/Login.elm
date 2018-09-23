module Pages.Login exposing (..)

import Http
import Task exposing (Task)

import Requests.Auth as Request

type Msg
  = SetUsername String
  | SetPassword String
  | Submit
  | Authenticated (Result Http.Error String)

type alias Model =
  { username : String
  , password : String
  , errorMsg : String
  , token : String
  }

initialModel : Model
initialModel =
  { username = ""
  , password = ""
  , errorMsg = ""
  , token = ""
  }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    SetUsername username ->
      ({ model | username = username }, Cmd.none)
    SetPassword password ->
      ({ model | password = password }, Cmd.none)
    Submit ->
      let
        authObj =
          { username = model.username
          , password = model.password
          }
        newMsg = Request.authenticate authObj
          |> Task.attempt Authenticated
      in
        (model, newMsg)
    Authenticated (Ok token ) ->
      ({ model | token = token }, Cmd.none)
    Authenticated (Err error ) ->
      ({ model | errorMsg = (toString error) }, Cmd.none)

