module Pages.EditGroup exposing (Model, Msg(..), addComponentToModel, init, initialModel, update)

import Components.Group
import Http
import Task exposing (Task)


type Msg
    = GroupMsg Components.Group.Msg


type alias Model =
    { groupComponent : Components.Group.Model
    }


initialModel : Model
initialModel =
    { groupComponent = Components.Group.initialModel
    }


init : Int -> String -> Task Http.Error Model
init groupId token =
    Task.map addComponentToModel (Components.Group.init groupId token)


addComponentToModel : Components.Group.Model -> Model
addComponentToModel componentModel =
    { initialModel | groupComponent = componentModel }


update : Msg -> Model -> String -> ( Model, Cmd Msg )
update msg model token =
    case msg of
        GroupMsg subMsg ->
            let
                ( newGroupComponentModel, newSubMsg ) =
                    Components.Group.update subMsg model.groupComponent token

                msg =
                    Cmd.map GroupMsg newSubMsg
            in
            ( { model | groupComponent = newGroupComponentModel }, msg )
