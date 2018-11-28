module Pages.Groups exposing (Model, Msg(..), addGroupsToModel, init, initialModel, update)

import Http
import Models.Group exposing (Group)
import Pages.Helper exposing (..)
import Port
import Requests.Base
import Requests.Group
import Task exposing (Task)


type Msg
    = ClickedDeleteGroup Int
    | CancelDeleteGroup
    | DeleteGroupRequest Int
    | DeleteGroup Int (Result Http.Error String)
    | PreviewGroupRequest Int
    | PreviewGroup Int (Result Http.Error String)


type alias Model =
    { groups : List Group
    , errorMsg : String
    , deletingGroup : Maybe Int
    }


initialModel : Model
initialModel =
    { groups = []
    , errorMsg = ""
    , deletingGroup = Nothing
    }


init : String -> Task Http.Error Model
init token =
    Task.map addGroupsToModel (Requests.Group.getAll token)


addGroupsToModel : List Group -> Model
addGroupsToModel groups =
    { initialModel | groups = groups }


update : Msg -> Model -> String -> ( Model, Cmd Msg )
update msg model token =
    case msg of
        ClickedDeleteGroup id ->
            ( { model | deletingGroup = Just id }, Cmd.none )

        CancelDeleteGroup ->
            ( { model | deletingGroup = Nothing }, Cmd.none )

        DeleteGroupRequest groupId ->
            let
                newMsg =
                    Requests.Group.delete groupId token
                        |> Task.attempt (DeleteGroup groupId)
            in
            ( model, newMsg )

        DeleteGroup id (Ok message) ->
            ( { model
                | groups = removeModelFromNullableIdList (Just id) model.groups
                , deletingGroup = Nothing
              }
            , Cmd.none
            )

        DeleteGroup id (Err error) ->
            ( { model | errorMsg = toString error }, Cmd.none )

        PreviewGroupRequest id ->
            let
                newMsg =
                    Requests.Base.getFileToken token
                        |> Task.attempt (PreviewGroup id)
            in
            ( model, newMsg )

        PreviewGroup id (Ok token) ->
            ( model, Port.openWindow (Requests.Group.previewUrl (Just id) token) )

        PreviewGroup id (Err error) ->
            ( { model | errorMsg = toString error }, Cmd.none )
