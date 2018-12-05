module Pages.Batches exposing (Model, Msg(..), addBatchesToModel, init, initialModel, update)

import Helpers.StringConversions as StringConversions
import Http
import Models.Batch exposing (Batch)
import Port
import Requests.Base
import Requests.Batch
import Task exposing (Task)


type Msg
    = DownloadFormRequest Int
    | DownloadForm Int (Result Http.Error String)


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
            ( { model | errorMsg = StringConversions.fromHttpError error }, Cmd.none )
