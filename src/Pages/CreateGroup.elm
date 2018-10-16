module Pages.CreateGroup exposing (Model, Msg(..), initialModel, update)

import Components.Group


type Msg
    = GroupMsg Components.Group.Msg


type alias Model =
    { groupComponent : Components.Group.Model
    }


initialModel : Model
initialModel =
    { groupComponent = Components.Group.initialModel
    }


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
