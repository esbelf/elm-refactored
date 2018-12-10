module Views.Batches exposing (view)

import Html exposing (..)
import Html.Attributes exposing (attribute, class, name, placeholder, type_, value)
import Html.Events exposing (onClick)
import Models.Batch exposing (Batch)
import Pages.Batches exposing (Model, Msg(..))
import Routes exposing (Route, href)


view : Model -> Html Msg
view model =
    div [ class "uk-margin" ]
        [ h1 [] [ text "Batches" ]
        , div []
            [ p [] [ text model.errorMsg ]
            ]
        , div []
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


viewBatchList : List Batch -> List (Html Msg)
viewBatchList batches =
    List.map viewBatch batches


viewBatch : Batch -> Html Msg
viewBatch batch =
    tr []
        [ th []
            [ a
                [ href (Routes.EditGroup batch.group_id) ]
                [ text batch.group_name ]
            ]
        , th [] [ text batch.start_date ]
        , th [] [ text (String.fromInt batch.census_count) ]
        , th []
            [ a [ onClick (DownloadFormRequest batch.id) ]
                [ text "Download" ]
            ]
        , th [] [ text batch.created_at ]
        , th [] [ text batch.user_email ]
        ]
