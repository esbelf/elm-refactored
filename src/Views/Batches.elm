module Views.Batches exposing (view)

import Html exposing (..)
import Html.Attributes exposing (attribute, class, href, id, name, placeholder, src, title, type_, value)
import Html.Events exposing (onClick)
import Json.Decode as JD
import Models.Batch exposing (Batch)
import Msg exposing (..)
import Pages.Batches exposing (Model)
import Port
import Route exposing (onClickRoute)
import Routes exposing (Route)


view : Model -> Html Msg
view model =
    div [ class "uk-margin uk-margin-top" ]
        [ div [ class "uk-flex uk-flex-wrap uk-flex-wrap around" ]
            [ h1 [ class "uk-width-1-2" ] [ text "Batches" ]
            , div [ class "uk-width-1-2" ]
                [ button
                    [ class "uk-button uk-button-primary uk-align-right"
                    , type_ "button"
                    ]
                    [ text "Upload Census" ]
                ]
            ]
        , div []
            [ p [] [ text model.errorMsg ]
            ]
        , viewFile model
        , div [ class "uk-child-width-1-1@s" ]
            [ table [ class "uk-table uk-table-striped" ]
                [ thead []
                    [ tr []
                        [ th [] [ text "Group Name" ]
                        , th [] [ text "Effective Date" ]
                        , th [] [ text "Forms Count" ]
                        , th [] [ text "File Size" ]
                        , th [] [ text "Created Date" ]
                        , th [] [ text "Created By" ]
                        , th [] []
                        ]
                    ]
                , tbody []
                    (viewBatchList model.batches)
                ]
            ]
        ]


viewFile : Model -> Html Msg
viewFile model =
    let
        filePreview =
            case model.file of
                Just i ->
                    viewFilePreview i

                Nothing ->
                    text "nothing"
    in
    div [ class "imageWrapper" ]
        [ input
            [ type_ "file"
            , Html.Attributes.id model.fileId
            , Html.Events.on "change"
                (JD.succeed (BatchesMsg Pages.Batches.FileSelected))
            ]
            []
        , filePreview
        ]


viewFilePreview : Port.FilePortData -> Html Msg
viewFilePreview file =
    img
        [ src file.contents
        , title file.filename
        ]
        []


viewBatchList : List Batch -> List (Html Msg)
viewBatchList batches =
    List.map viewBatch batches


viewBatch : Batch -> Html Msg
viewBatch batch =
    tr []
        [ th []
            [ a ([] ++ onClickRoute (Routes.EditGroup batch.group_id))
                [ text batch.group_name ]
            ]
        , th [] [ text batch.start_date ]
        , th [] [ text (toString batch.census_count) ]
        , th []
            [ a [ onClick (BatchesMsg (Pages.Batches.DownloadFormRequest batch.id)) ]
                [ text "Download" ]
            ]
        , th [] [ text batch.created_at ]
        , th [] [ text batch.user_email ]
        ]
