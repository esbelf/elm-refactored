module Pages.Groups exposing (..)

import Http
import Task exposing (Task)

import Pages.Helper exposing (..)
import Models.Group exposing (Group)
import Requests.Group

type Msg
  = DeleteGroupRequest Int
  | DeleteGroup Int (Result Http.Error String)
  --| PreviewGroupRequest Int
  --| PreviewGroup (Result Http.Error String)

type alias Model =
  { groups : List Group
  , errorMsg : String
  }

initialModel : Model
initialModel =
  { groups = []
  , errorMsg = ""
  }

init : String -> Task Http.Error Model
init token =
  Task.map addGroupsToModel (Requests.Group.getAll token)

addGroupsToModel : (List Group) -> Model
addGroupsToModel groups =
  { initialModel | groups = groups }

update : Msg -> Model -> String -> ( Model, Cmd Msg )
update msg model token =
  case msg of
    DeleteGroupRequest groupId ->
      let
        newMsg = (Requests.Group.delete groupId token)
          |> Task.attempt (DeleteGroup groupId)
      in
        (model, newMsg)
    DeleteGroup id (Ok message) ->
      ({ model | groups = removeModelFromList id model.groups }, Cmd.none)

    DeleteGroup id (Err error) ->
      ({ model | errorMsg = (toString error) }, Cmd.none)



