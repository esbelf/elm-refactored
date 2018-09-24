module Pages.Users exposing (..)

import Http
import Task exposing (Task)

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

init : Task Http.Error Model
init =
    Task.map addUsersToModel Requests.User.fetch

addUsersToModel : List User -> Model
addUsersToModel users =
  { initialModel | users = users }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    DeleteUser id (Ok message) ->
      ({ model | users = removeUser id model.users }, Cmd.none)

    DeleteUser id (Err error) ->
      ({ model | errorMsg = (toString error) }, Cmd.none)

    DeleteUserRequest userId ->
      let
        newMsg = Requests.User.delete userId
          |> Task.attempt (DeleteUser userId)
      in
        (model, newMsg)

removeUser : Int -> List User -> List User
removeUser id =
   List.filter (\user -> user.id /= id)

