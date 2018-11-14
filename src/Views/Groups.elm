module Views.Groups exposing (view)

import Html exposing (..)
import Html.Attributes exposing (attribute, class, href, name, placeholder, type_, value)
import Html.Events exposing (onClick)
import Models.Group exposing (Group)
import Msg exposing (..)
import Pages.Groups exposing (Model)
import Route exposing (onClickRoute)
import Routes exposing (Route)


view : Model -> Html Msg
view model =
    div [ class "uk-margin uk-margin-top" ]
        [ div [ class "uk-flex uk-flex-wrap uk-flex-wrap around" ]
            [ h1 [ class "uk-width-1-2" ] [ text "Groups" ]
            , div [ class "uk-width-1-2" ]
                [ a ([ class "uk-button-primary uk-button uk-align-right" ] ++ onClickRoute Routes.CreateGroup)
                    [ text "Create Group" ]
                ]
            ]
        , div []
            [ p [] [ text model.errorMsg ]
            ]
        , div []
            [ table [ class "uk-table uk-table-striped" ]
                [ thead []
                    [ tr []
                        [ th [] [ text "Name" ]
                        , th [] []
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
        [ td []
            [ a ([ class "uk-link-text" ] ++ onClickRoute (Routes.EditGroup group.id))
                [ text group.name ]
            ]
        , td []
            [ button
                [ class "uk-button uk-button-default uk-button-small"
                , type_ "button"
                , onClick (GroupsMsg (Pages.Groups.PreviewGroupRequest group.id))
                ]
                [ text "Preview" ]
            ]
        , td []
            [ button
                [ class "uk-button uk-button-default uk-button-small"
                , type_ "button"
                , onClick (SetRoute (Routes.CreateBatch group.id))
                ]
                [ text "Create Batch" ]
            ]
        , td []
            [ button
                [ class "uk-button uk-button-danger uk-button-small"
                , type_ "button"
                ]
                [ text "Delete" ]
            ]
        ]
