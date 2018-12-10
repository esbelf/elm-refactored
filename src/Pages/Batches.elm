module Pages.Batches exposing (Model, Msg(..), init, update)

import Helpers.StringConversions as StringConversions
import Http
import Models.Batch exposing (Batch)
import Port
import Requests.Base
import Requests.Batch
import Task exposing (Task)


type Msg
    = BatchesLoaded (Result Http.Error (List Batch))
    | DownloadFormRequest Int
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


loadCmd : String -> Cmd Msg
loadCmd token =
    Requests.Batch.getAll token BatchesLoaded


init : String -> ( Model, Cmd Msg )
init token =
    ( initialModel, loadCmd token )


addBatchesToModel : List Batch -> Model
addBatchesToModel batches =
    { initialModel | batches = batches }


update : Msg -> Model -> String -> ( Model, Cmd Msg )
update msg model token =
    case msg of
        BatchesLoaded (Ok batches) ->
            ( { model | batches = batches }, Cmd.none )

        BatchesLoaded (Err error) ->
            ( { model | errorMsg = StringConversions.fromHttpError error }
            , Cmd.none
            )

        DownloadFormRequest id ->
            let
                newMsg =
                    Requests.Base.getFileToken token (DownloadForm id)
            in
            ( model, newMsg )

        DownloadForm id (Ok fileToken) ->
            ( model, Port.openWindow (Requests.Batch.formUrl id fileToken) )

        DownloadForm id (Err error) ->
            ( { model | errorMsg = StringConversions.fromHttpError error }, Cmd.none )
