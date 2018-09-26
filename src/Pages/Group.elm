module Pages.Group exposing (..)

import Http
import Task exposing (Task)

import Models.Group exposing (Group)
import Requests.Group

type Msg
  = SetName String
  | SetPaymentMode String
  | SetFormType String

type alias Model =
  { group : Group
  , errorMsg : String
  , id : Int
  , inputName : String
  , inputPaymentMode : Int
  , inputFormType : String
  }

initialModel : Model
initialModel =
  { group = Models.Group.init
  , errorMsg = ""
  , id = 0
  , inputName = ""
  , inputPaymentMode = 0
  , inputFormType = ""
  }

init : Int -> Task Http.Error Model
init groupId =
  Task.map addGroupToModel (Requests.Group.get groupId)

addGroupToModel : Group -> Model
addGroupToModel group =
  { initialModel |
    id = group.id,
    group = group,
    inputName = group.name,
    inputPaymentMode = group.payment_mode,
    inputFormType = group.form_type
  }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    SetName name ->
      ({ model | inputName = name }, Cmd.none)
    SetPaymentMode paymentMode ->
      let
        newPaymentMode = String.toInt paymentMode |> Result.toMaybe |> Maybe.withDefault model.inputPaymentMode
      in
        ({ model | inputPaymentMode = newPaymentMode }, Cmd.none)
    SetFormType formType ->
      ({ model | inputFormType = formType }, Cmd.none)


