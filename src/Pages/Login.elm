module Pages.Login exposing (Model, Msg(..), initialModel, update)

import Helpers.StringConversions as StringConversions
import Http
import Models.Session exposing (Session)
import Port
import Requests.Auth as Request
import Task exposing (Task)


type Msg
    = SetEmail String
    | SetPassword String
    | Submit
    | Authenticated (Result Http.Error Session)


type alias Model =
    { email : String
    , password : String
    , errorMsg : String
    , session : Maybe Session
    }


initialModel : Model
initialModel =
    { email = ""
    , password = ""
    , errorMsg = ""
    , session = Nothing
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetEmail email ->
            ( { model | email = email }, Cmd.none )

        SetPassword password ->
            ( { model | password = password }, Cmd.none )

        Submit ->
            let
                authObj =
                    { email = model.email
                    , password = model.password
                    }

                newMsg =
                    Request.authenticate authObj
                        |> Task.attempt Authenticated
            in
            ( model, newMsg )

        Authenticated (Ok session) ->
            storeSession session model

        Authenticated (Err error) ->
            ( { model
                | session = Nothing
                , errorMsg = StringConversions.fromHttpError error
              }
            , Cmd.none
            )


storeSession : Session -> Model -> ( Model, Cmd Msg )
storeSession newSession model =
    let
        newModel =
            { model
                | session = Just newSession
                , errorMsg = ""
            }

        storageModel =
            Models.Session.toStorageModel newSession
    in
    ( newModel, Port.setStorage storageModel )
