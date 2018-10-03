module Views.Batches exposing (view)

import Msg exposing (..)
import Pages.Batches exposing (Model)
import Models.Batch exposing (Batch)
import Route exposing (onClickRoute)
import Routes exposing (Route)

import Html exposing (..)
-- import Html.Events exposing (onClick)
import Html.Attributes exposing (attribute, class, href, name, type_, value, placeholder)

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
      [ a ([] ++ onClickRoute (Routes.Group batch.group_id) )
        [ text batch.group_name ]
      ]
    , th [] [ text batch.start_date ]
    , th [] [ text (toString batch.census_count) ]
    , th [] [ text "Download link add here" ]
    , th [] [ text batch.created_at ]
    , th [] [ text batch.user_email ]
    ]
