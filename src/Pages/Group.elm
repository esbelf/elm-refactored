module Pages.Group exposing (..)

import Http
import Task exposing (Task)

import Models.Group exposing (Group)
import Requests.Group

type Msg
  = UpdateGroupRequest

type alias Model =
  { group : Maybe Group
  , errorMsg : String
  , id : Int
  }

initialModel : Model
initialModel =
  { group = Nothing
  , errorMsg = ""
  , id = 0
  }

init : Int -> Task Http.Error Model
init groupId =
  Task.map addGroupToModel (Requests.Group.get groupId)

addGroupToModel : Group -> Model
addGroupToModel group =
  { initialModel |
    id = group.id
  }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    UpdateGroupRequest ->
      (model, Cmd.none)
