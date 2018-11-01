module Pages.Batches exposing (Model, Msg(..), addBatchesToModel, init, initialModel, update)

import Debug
import Http
import Models.Batch exposing (Batch)
import Port
import Requests.Base
import Requests.Batch
import Task exposing (Task)


type Msg
    = DownloadFormRequest Int
    | DownloadForm Int (Result Http.Error String)
    | FileSelected
    | FileRead Port.FilePortData
    | FileUpload (Result Http.Error String)


type alias Model =
    { batches : List Batch
    , errorMsg : String
    , fileId : String
    , file : Maybe Port.FilePortData
    }


initialModel : Model
initialModel =
    { batches = []
    , errorMsg = ""
    , fileId = "FileInputId"
    , file = Nothing
    }


init : String -> Task Http.Error Model
init token =
    Task.map addBatchesToModel (Requests.Batch.getAll token)


addBatchesToModel : List Batch -> Model
addBatchesToModel batches =
    { initialModel | batches = batches }


update : Msg -> Model -> String -> ( Model, Cmd Msg )
update msg model token =
    case msg of
        DownloadFormRequest id ->
            let
                newMsg =
                    Requests.Base.getFileToken token
                        |> Task.attempt (DownloadForm id)
            in
            ( model, newMsg )

        DownloadForm id (Ok token) ->
            ( model, Port.openWindow (Requests.Batch.formUrl id token) )

        DownloadForm id (Err error) ->
            ( { model | errorMsg = toString error }, Cmd.none )

        FileSelected ->
            let
                log =
                    Debug.log "File Selected" model.fileId
            in
            ( model, Port.fileSelected model.fileId )

        FileRead data ->
            let
                log =
                    Debug.log "File Read" data

                newFile =
                    { contents = data.contents
                    , filename = data.filename
                    }

                newMsg =
                    Requests.Batch.create newFile token
                        |> Task.attempt FileUpload
            in
            ( { model | file = Just newFile }, newMsg )

        FileUpload (Ok message) ->
            let
                log =
                    Debug.log "File Received Successful" message
            in
            ( model, Cmd.none )

        FileUpload (Err error) ->
            ( { model | errorMsg = toString error }, Cmd.none )
