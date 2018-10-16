module Pages.Login exposing (Model, Msg(..), initialModel, setStorageHelper, update)

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
            setStorageHelper
                { model
                    | session = Just session
                    , errorMsg = ""
                }

        Authenticated (Err error) ->
            ( { model
                | session = Nothing
                , errorMsg = toString error
              }
            , Cmd.none
            )


setStorageHelper : Model -> ( Model, Cmd Msg )
setStorageHelper model =
    let
        portModel =
            Models.Session.toPortModel model.session
    in
    ( model, Port.setStorage portModel )
