module Pages.Users exposing (..)

import Http
import Task exposing (Task)

import Pages.Helper exposing (..)
import Models.User exposing (User)
import Requests.User

type Msg
  = DeleteUserRequest Int
  | DeleteUser Int (Result Http.Error String)

type alias Model =
  { users : List User
  , errorMsg : String
  }

initialModel : Model
initialModel =
  { users = []
  , errorMsg = ""
  }

init : String -> Task Http.Error Model
init token =
    Task.map addUsersToModel (Requests.User.fetch token)

addUsersToModel : List User -> Model
addUsersToModel users =
  { initialModel | users = users }

update : Msg -> Model -> String -> ( Model, Cmd Msg )
update msg model token =
  case msg of
    DeleteUser id (Ok message) ->
      ({ model | users = removeModelFromList id model.users }, Cmd.none)

    DeleteUser id (Err error) ->
      ({ model | errorMsg = (toString error) }, Cmd.none)

    DeleteUserRequest userId ->
      let
        newMsg = Requests.User.delete userId token
          |> Task.attempt (DeleteUser userId)
      in
        (model, newMsg)


