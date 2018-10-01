module Views.Groups exposing (view)

import Msg exposing (..)
import Pages.Groups exposing (Model)
import Models.Group exposing (Group)
import Route exposing (onClickRoute)
import Routes exposing (Route)

import Html exposing (..)
-- import Html.Events exposing (onClick)
import Html.Attributes exposing (attribute, class, href, name, type_, value, placeholder)

view : Model -> Html Msg
view model =
  div [ class "uk-margin" ]
    [ h1 [] [ text "Groups"]
    , div []
      [ p [] [ text model.errorMsg ]
      ]
    , div []
      [ table [ class "uk-table uk-table-striped" ]
        [ thead []
          [ tr []
            [ th [] [ text "Name" ]
            , th [] [ ]
            ]
          ]
        , tbody []
          (viewGroupList model.groups)
        ]
      ]
    ]

viewGroupList : List Group -> List (Html Msg)
viewGroupList groups =
  List.map viewGroup groups

viewGroup : Group -> Html Msg
viewGroup group =
  tr []
    [ td [] [ a ([ class "uk-link-text" ] ++ onClickRoute (Routes.Group group.id))
        [ text group.name ]
      ]
    , td []
      [ button
        ([ class "uk-button uk-button-default uk-button-small"
        , type_ "button"
        ] ++ onClickRoute (Routes.GroupPreview group.id) )
        [ text "Preview" ]
      ]
    , td []
      [ button
        [ class "uk-button uk-button-danger uk-button-small"
        , type_ "button"
        ] [ text "Delete" ]
      ]
    ]