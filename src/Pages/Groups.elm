module Pages.Groups exposing (Model, Msg(..), init, initialModel, update)

import Browser.Navigation as Nav
import Helpers.StringConversions as StringConversions
import Http
import Models.Group exposing (Group)
import Pages.Helper exposing (..)
import Port
import Requests.Base
import Requests.Group
import Task exposing (Task)


type Msg
    = GroupsLoaded (Result Http.Error (List Group))
    | ClickedDeleteGroup Int
    | CancelDeleteGroup
    | DeleteGroupRequest Int
    | DeleteGroup Int (Result Http.Error String)
    | PreviewGroupRequest Int
    | PreviewGroup Int (Result Http.Error String)
    | DuplicateGroupRequest Int
    | DuplicateGroup Int (Result Http.Error Group)


type alias Model =
    { groups : List Group
    , errorMsg : String
    , deletingGroup : Maybe Int
    , navKey : Nav.Key
    }


initialModel : Nav.Key -> Model
initialModel navKey =
    { groups = []
    , errorMsg = ""
    , deletingGroup = Nothing
    , navKey = navKey
    }


loadCmd : String -> Cmd Msg
loadCmd token =
    Requests.Group.getAll token GroupsLoaded


init : String -> Nav.Key -> ( Model, Cmd Msg )
init token navKey =
    ( initialModel navKey
    , loadCmd token
    )


update : Msg -> Model -> String -> ( Model, Cmd Msg )
update msg model token =
    case msg of
        GroupsLoaded (Ok groups) ->
            ( { model | groups = groups }, Cmd.none )

        GroupsLoaded (Err error) ->
            ( { model | errorMsg = StringConversions.fromHttpError error }, Cmd.none )

        ClickedDeleteGroup id ->
            ( { model | deletingGroup = Just id }, Cmd.none )

        CancelDeleteGroup ->
            ( { model | deletingGroup = Nothing }, Cmd.none )

        DeleteGroupRequest groupId ->
            let
                newMsg =
                    Requests.Group.delete groupId token (DeleteGroup groupId)
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
            ( { model | errorMsg = StringConversions.fromHttpError error }, Cmd.none )

        PreviewGroupRequest id ->
            let
                newMsg =
                    Requests.Base.getFileToken token (PreviewGroup id)
            in
            ( model, newMsg )

        PreviewGroup id (Ok fileToken) ->
            ( model, Port.openWindow (Requests.Group.previewUrl (Just id) fileToken) )

        PreviewGroup id (Err error) ->
            ( { model | errorMsg = StringConversions.fromHttpError error }, Cmd.none )

        DuplicateGroupRequest groupId ->
            let
                newMsg =
                    Requests.Group.duplicate groupId token (DuplicateGroup groupId)
            in
            ( model, newMsg )

        DuplicateGroup id (Ok newGroup) ->
            let
                newId =
                    newGroup.id
                        |> Maybe.map String.fromInt
                        |> Maybe.withDefault ""

                newLoc =
                    "groups/" ++ newId
            in
            ( model, Nav.replaceUrl model.navKey newLoc )

        DuplicateGroup id (Err error) ->
            ( { model | errorMsg = StringConversions.fromHttpError error }, Cmd.none )
