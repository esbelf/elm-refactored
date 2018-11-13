module Pages.CreateBatch exposing (Model, Msg(..), initNew, update, view)

import Html exposing (Attribute, Html, button, div, fieldset, input, li, span, text, ul)
import Html.Attributes exposing (class, disabled, id, name, placeholder, tabindex, type_, value)
import Html.Events exposing (onInput, onSubmit)
import Http
import Json.Decode as JD
import Models.Batch exposing (BatchForm)
import Navigation
import Port
import Requests.Base
import Requests.Batch


{-| !TODO: generalize Token type outside of this module
-}
type alias Token =
    String


type alias Form =
    BatchForm


type alias Model =
    { token : Token
    , status : Status
    }


type Status
    = EditingNew (List Problem) Form
    | Creating Form


type Problem
    = InvalidEntry ValidatedField String
    | ServerError String


type ValidatedField
    = StartDate
    | FileContents


fieldsToValidate : List ValidatedField
fieldsToValidate =
    [ StartDate
    , FileContents
    ]


{-| Marks that we've trimmed the form's fields, so we don't accidentally send
it to the server without having trimmed it!
-}
type TrimmedForm
    = Trimmed Form


formUploadId : String
formUploadId =
    "census_upload_file_input"


emptyForm : Int -> Form
emptyForm groupId =
    { startDate = ""
    , fileData = ""
    , fileName = ""
    , groupId = groupId
    }


initNew : Token -> Int -> Model
initNew token groupId =
    { token = token
    , status = EditingNew [] (emptyForm groupId)
    }



-- initEdit would take a token and batchId, return a 'Loading' status and a data load Cmd
-- UPDATE


type Msg
    = ClickedSave
    | EnteredStartDate String
    | FileSelected
    | FileRead Port.FilePortData
    | CompletedCreate (Result Http.Error String)


update : Msg -> Model -> Token -> ( Model, Cmd Msg )
update msg model token =
    case msg of
        ClickedSave ->
            model
                |> save
                |> Tuple.mapFirst (\status -> { model | status = status })

        EnteredStartDate dateStr ->
            updateForm (\form -> { form | startDate = dateStr }) model

        FileSelected ->
            ( model, Port.fileSelected formUploadId )

        FileRead portData ->
            updateForm
                (\form ->
                    { form
                        | fileData = portData.contents
                        , fileName = portData.filename
                    }
                )
                model

        CompletedCreate (Ok batch) ->
            ( model
            , Navigation.newUrl "/batches"
              -- Hack for now, pending routing upgrade
            )

        CompletedCreate (Err error) ->
            ( { model | status = savingError error model.status }
            , Cmd.none
            )


updateForm : (Form -> Form) -> Model -> ( Model, Cmd Msg )
updateForm transform model =
    let
        newModel =
            case model.status of
                EditingNew errors form ->
                    { model | status = EditingNew errors (transform form) }

                Creating form ->
                    { model | status = Creating (transform form) }
    in
    ( newModel, Cmd.none )


{-| Note that save returns a (_Status_, Cmd Msg) tuple
(the ClickedSave branch in update takes care of updating the status field of model
based on the value returned)
-}
save : Model -> ( Status, Cmd Msg )
save model =
    case model.status of
        EditingNew _ form ->
            case validate form of
                Ok validForm ->
                    ( Creating form
                    , create validForm model.token
                        |> Http.send CompletedCreate
                    )

                Err problems ->
                    ( EditingNew problems form
                    , Cmd.none
                    )

        _ ->
            -- In a state where saving is not allowed. Ignore.
            ( model.status, Cmd.none )


savingError : Http.Error -> Status -> Status
savingError error status =
    let
        problems =
            [ ServerError (errorDesc error) ]
    in
    case status of
        Creating form ->
            EditingNew problems form

        _ ->
            status


errorDesc : Http.Error -> String
errorDesc error =
    error
        |> Requests.Base.maybeErrorDesc
        |> Maybe.withDefault "Error saving Batch"


validate : Form -> Result (List Problem) TrimmedForm
validate form =
    let
        trimmedForm =
            trimFields form
    in
    case List.concatMap (validateField trimmedForm) fieldsToValidate of
        [] ->
            Ok trimmedForm

        problems ->
            Err problems


validateField : TrimmedForm -> ValidatedField -> List Problem
validateField (Trimmed form) field =
    List.map (InvalidEntry field) <|
        case field of
            StartDate ->
                if String.isEmpty form.startDate then
                    [ "Start Date can't be blank" ]

                else
                    []

            FileContents ->
                if String.isEmpty form.fileData then
                    [ "You need to attach a census file" ]

                else
                    []


{-| Don't trim while the user is typing! That would be super annoying.
Instead, trim only on submit.
-}
trimFields : Form -> TrimmedForm
trimFields form =
    Trimmed
        { startDate = String.trim form.startDate
        , fileData = form.fileData
        , fileName = form.fileName
        , groupId = form.groupId
        }



-- HTTP


create : TrimmedForm -> Token -> Http.Request String
create (Trimmed form) token =
    Requests.Batch.create form token



-- VIEW


view : Model -> Html Msg
view model =
    let
        formHtml =
            case model.status of
                EditingNew problems form ->
                    viewProblems problems
                        :: viewForm form (newBatchSaveButton [])

                Creating form ->
                    viewForm form (newBatchSaveButton [ disabled True ])
    in
    Html.form [ onSubmit ClickedSave ]
        [ fieldset [ class "uk-fieldset" ]
            formHtml
        ]


viewProblems : List Problem -> Html Msg
viewProblems problems =
    ul [ class "error-messages" ]
        (List.map viewProblem problems)


viewProblem : Problem -> Html Msg
viewProblem problem =
    li [] [ text <| problemMessage problem ]


problemMessage : Problem -> String
problemMessage problem =
    case problem of
        InvalidEntry _ message ->
            message

        ServerError message ->
            message


viewForm : Form -> Html Msg -> List (Html Msg)
viewForm fields saveButton =
    [ div [ class "uk-child-width-1-1@s uk-child-width-1-2@m" ]
        [ div [ class "uk-margin" ]
            [ span [ class "uk-label" ]
                [ text "Start Date" ]
            , input
                [ class "uk-input"
                , name "start_date"
                , type_ "input"
                , value fields.startDate
                , placeholder "Start Date"
                , onInput EnteredStartDate
                ]
                []
            ]
        ]
    , viewFileUploadControl fields
    , div [ class "uk-child-width-1-1@s" ] [ saveButton ]
    ]


viewFileUploadControl : Form -> Html Msg
viewFileUploadControl fields =
    let
        fileChosen =
            not <| String.isEmpty fields.fileName

        buttonText =
            if fileChosen then
                "Change Census File"

            else
                "Select Census File"
    in
    div [ class "uk-child-width-1-1@s" ]
        [ div [ class "uk-margin" ]
            [ div [ class "uk-form-custom" ]
                [ input
                    [ type_ "file"
                    , Html.Attributes.id formUploadId
                    , Html.Events.on "change"
                        (JD.succeed FileSelected)
                    ]
                    []
                , button
                    [ class "uk-button uk-button-default"
                    , type_ "button"
                    , tabindex -1
                    ]
                    [ text buttonText ]
                , text fields.fileName
                ]
            ]
        ]


newBatchSaveButton : List (Attribute Msg) -> Html Msg
newBatchSaveButton extraAttrs =
    saveBatchButton "Create Batch" extraAttrs


saveBatchButton : String -> List (Attribute Msg) -> Html Msg
saveBatchButton caption extraAttrs =
    button (class "uk-button uk-button-primary uk-margin-small" :: extraAttrs)
        [ text caption ]
