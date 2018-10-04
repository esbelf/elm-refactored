module Pages.Login exposing (..)

import Http
import Task exposing (Task)
-- import Json.Decode as Decode
import Port
import Requests.Auth as Request
import Models.Session exposing (Session)

type Msg
  = SetEmail String
  | SetPassword String
  | Submit
  | Authenticated (Result Http.Error Session)

type alias Model =
  { email : String
  , password : String
  , errorMsg : String
  , session : Session
  }

initialModel : Model
initialModel =
  { email = ""
  , password = ""
  , errorMsg = ""
  , session = (Models.Session.init "" "")
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
    Authenticated (Ok session ) ->
      setStorageHelper { model | session = session }
    Authenticated (Err error ) ->
      ({ model | errorMsg = (toString error) }, Cmd.none)


setStorageHelper : Model -> ( Model, Cmd Msg )
setStorageHelper model =
  let
    session = model.session
    portModel =
      { token = session.token
      , exp = session.exp
      }
  in
    ( model, Port.setStorage portModel )



