module Pages.Users exposing (Model, Msg(..), addUsersToModel, init, initialModel, update)

import Helpers.StringConversions as StringConversions
import Http
import Models.User exposing (User)
import Pages.Helper exposing (..)
import Requests.User
import Task exposing (Task)


type Msg
    = DeleteUserRequest Int
    | DeleteUser Int (Result Http.Error String)


type alias Model =
    { users : List User
    , errorMsg : String
    }


initialModel : Model
initialModel =
    { users = []
    , errorMsg = ""
    }


init : String -> Task Http.Error Model
init token =
    Task.map addUsersToModel (Requests.User.fetch token)


addUsersToModel : List User -> Model
addUsersToModel users =
    { initialModel | users = users }


update : Msg -> Model -> String -> ( Model, Cmd Msg )
update msg model token =
    case msg of
        DeleteUser id (Ok message) ->
            ( { model | users = removeModelFromList id model.users }, Cmd.none )

        DeleteUser id (Err error) ->
            ( { model | errorMsg = StringConversions.fromHttpError error }, Cmd.none )

        DeleteUserRequest userId ->
            let
                newMsg =
                    Requests.User.delete userId token
                        |> Task.attempt (DeleteUser userId)
            in
            ( model, newMsg )
