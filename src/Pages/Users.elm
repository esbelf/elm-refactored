module Pages.Users exposing (Model, Msg(..), init, update)

import Helpers.StringConversions as StringConversions
import Http
import Models.User exposing (User)
import Pages.Helper exposing (..)
import Requests.User
import Task exposing (Task)


type Msg
    = UsersLoaded (Result Http.Error (List User))
    | DeleteUserRequest Int
    | UserDeleted Int (Result Http.Error ())


type alias Model =
    { users : List User
    , errorMsg : String
    }


initialModel : Model
initialModel =
    { users = []
    , errorMsg = ""
    }


init : String -> ( Model, Cmd Msg )
init token =
    ( initialModel
    , Requests.User.fetch token UsersLoaded
    )


update : Msg -> Model -> String -> ( Model, Cmd Msg )
update msg model token =
    case msg of
        UsersLoaded (Ok users) ->
            ( { model | users = users }, Cmd.none )

        UsersLoaded (Err error) ->
            ( { model | errorMsg = StringConversions.fromHttpError error }, Cmd.none )

        UserDeleted id (Ok _) ->
            ( { model | users = removeModelFromList id model.users }, Cmd.none )

        UserDeleted id (Err error) ->
            ( { model | errorMsg = StringConversions.fromHttpError error }, Cmd.none )

        DeleteUserRequest userId ->
            let
                newMsg =
                    Requests.User.delete userId token (UserDeleted userId)
            in
            ( model, newMsg )
