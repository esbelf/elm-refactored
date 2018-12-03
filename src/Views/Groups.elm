module Views.Groups exposing (view)

import Html exposing (..)
import Html.Attributes exposing (attribute, class, href, name, placeholder, type_, value)
import Html.Events exposing (onClick)
import Models.Group exposing (Group)
import Msg exposing (..)
import Pages.Groups exposing (Model)
import Route exposing (onClickRoute)
import Routes exposing (Route)
import Views.Modal as Modal exposing (ModalButtonStyle(..), modalButton)


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
        , viewDeletingModalIfNeeded model
        ]


viewGroupList : List Group -> List (Html Msg)
viewGroupList groups =
    List.map viewGroup groups


viewGroup : Group -> Html Msg
viewGroup group =
    case group.id of
        Nothing ->
            tr []
                [ td [] [ text group.name ] ]

        Just groupId ->
            tr []
                [ td []
                    [ a ([ class "uk-link-text" ] ++ onClickRoute (Routes.EditGroup groupId))
                        [ text group.name ]
                    ]
                , td []
                    [ button
                        [ class "uk-button uk-button-default uk-button-small"
                        , type_ "button"
                        , onClick (GroupsMsg (Pages.Groups.PreviewGroupRequest groupId))
                        ]
                        [ text "Preview" ]
                    ]
                , td []
                    [ button
                        [ class "uk-button uk-button-default uk-button-small"
                        , type_ "button"
                        , onClick (SetRoute (Routes.CreateBatch groupId))
                        ]
                        [ text "Create Batch" ]
                    ]
                , td []
                    [ button
                        [ class "uk-button uk-button-default uk-button-small"
                        , type_ "button"
                        , onClick (GroupsMsg (Pages.Groups.DuplicateGroupRequest groupId))
                        ]
                        [ text "Copy" ]
                    , button
                        [ class "uk-button uk-button-danger uk-button-small"
                        , type_ "button"
                        , onClick (GroupsMsg (Pages.Groups.ClickedDeleteGroup groupId))
                        ]
                        [ text "Delete" ]
                    ]
                ]


viewDeletingModalIfNeeded : Model -> Html Msg
viewDeletingModalIfNeeded model =
    case model.deletingGroup of
        Just groupId ->
            viewDeletingModal model groupId

        Nothing ->
            text ""


viewDeletingModal : Model -> Int -> Html Msg
viewDeletingModal model groupId =
    let
        maybeGroup =
            model.groups
                |> List.filter (\g -> g.id == model.deletingGroup)
                |> List.head
    in
    case maybeGroup of
        Just group ->
            let
                content =
                    p []
                        [ text
                            ("Remove group '"
                                ++ group.name
                                ++ "' ? This cannot be undone. Are you sure?"
                            )
                        ]

                buttons =
                    [ modalButton "Cancel" (GroupsMsg Pages.Groups.CancelDeleteGroup) ModalDefault
                    , modalButton "Delete" (GroupsMsg <| Pages.Groups.DeleteGroupRequest groupId) ModalDanger
                    ]
            in
            Modal.displayModal "Delete Group" content buttons

        Nothing ->
            text ""
