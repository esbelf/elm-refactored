module Pages.Batches exposing (..)

import Http
import Task exposing (Task)

-- import Pages.Helper exposing (..)
import Models.Batch exposing (Batch)
import Requests.Batch

--type Msg
--  = GetGroupRequest Int
--  | GetGroup Int (Result Http.Error Group)

type alias Model =
  { batches : List Batch
  , errorMsg : String
  }

initialModel : Model
initialModel =
  { batches = []
  , errorMsg = ""
  }

init : String -> Task Http.Error Model
init token =
  Task.map addBatchesToModel (Requests.Batch.getAll token)

addBatchesToModel : (List Batch) -> Model
addBatchesToModel batches =
  { initialModel | batches = batches }

--update : Msg -> Model -> String -> (Model, Cmd Msg)
--update msg model token =
--  case msg of
--    GetGroupRequest groupId ->

