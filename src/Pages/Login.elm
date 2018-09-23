module Pages.Login exposing (..)

import Http
import Task exposing (Task)
import Json.Decode as Decode

import Requests.Auth as Request

type Msg
  = SetEmail String
  | SetPassword String
  | Submit
  | Authenticated (Result Http.Error String)

type alias Model =
  { email : String
  , password : String
  , errorMsg : String
  , token : String
  }

initialModel : Model
initialModel =
  { email = ""
  , password = ""
  , errorMsg = ""
  , token = ""
  }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    SetEmail email ->
      ({ model | email = email }, Cmd.none)
    SetPassword password ->
      ({ model | password = password }, Cmd.none)
    Submit ->
      let
        authObj =
          { email = model.email
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

