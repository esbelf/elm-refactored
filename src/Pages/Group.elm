module Pages.Group exposing (..)

import Http
import Task exposing (Task)

import Models.Group exposing (Group)
import Requests.Group

type Msg
  = SetName String
  | SetPaymentMode String
  | SetFormType String
  | SetDisclosure String
  | UpdateGroupRequest
  | UpdateGroup (Result Http.Error Group)

type alias Model =
  { group : Group
  , errorMsg : String
  , id : Int
  }

initialModel : Model
initialModel =
  { group = Models.Group.init
  , errorMsg = ""
  , id = 0
  }

init : Int -> Task Http.Error Model
init groupId =
  Task.map addGroupToModel (Requests.Group.get groupId)

addGroupToModel : Group -> Model
addGroupToModel group =
  { initialModel |
    id = group.id,
    group = group
  }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    SetName name ->
      let
        oldGroup = model.group
      in
        ({ model | group = { oldGroup | name = name } }, Cmd.none)

    SetPaymentMode paymentMode ->
      let
        oldGroup = model.group
        newPaymentMode = String.toInt paymentMode
          |> Result.toMaybe
          |> Maybe.withDefault oldGroup.payment_mode
      in
        ({ model | group = { oldGroup | payment_mode = newPaymentMode } }, Cmd.none)

    SetFormType formType ->
      let
        oldGroup = model.group
      in
        ({ model | group = { oldGroup | form_type = formType } }, Cmd.none)
    SetDisclosure disclosure ->
      let
        oldGroup = model.group
      in
        ({ model | group = { oldGroup | disclosure = disclosure } }, Cmd.none)
    UpdateGroupRequest ->
      let
        newMsg = Requests.Group.update model.group
          |> Task.attempt UpdateGroup
      in
        (model, newMsg)

    UpdateGroup (Ok updatedGroup) ->
      ({ model | group = updatedGroup }, Cmd.none)

    UpdateGroup (Err error) ->
      ({ model | errorMsg = (toString error) }, Cmd.none)

