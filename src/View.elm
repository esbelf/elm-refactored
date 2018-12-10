module View exposing (view)

-- import Debug

import Browser
import Html exposing (..)
import Html.Attributes exposing (attribute, class, href, style)
import Html.Events exposing (onClick)
import Model exposing (Model, getPage)
import Models.Session exposing (Session)
import Msg exposing (..)
import Page exposing (..)
import Pages.CreateBatch
import Routes exposing (Route, href)
import Views.Batches
import Views.GroupForm
import Views.Groups
import Views.Login
import Views.Users


view : Model -> Browser.Document Msg
view model =
    { title = "EasyINS"
    , body =
        [ header model
        , div [ class "uk-container" ]
            [ mainContent model ]
        ]
    }


mainContent : Model -> Html Msg
mainContent model =
    let
        page =
            getPage model.pageState

        session =
            model.session
    in
    case page of
        Blank ->
            text "Blank Page"

        Home ->
            text "Home Page, I would like this page to be visible to non users with some propaganda."

        Error errorMessage ->
            text errorMessage

        Groups pageModel ->
            Views.Groups.view pageModel
                |> Html.map GroupsMsg

        EditGroup pageModel ->
            Views.GroupForm.view pageModel
                |> Html.map EditGroupMsg

        CreateGroup pageModel ->
            Views.GroupForm.view pageModel
                |> Html.map CreateGroupMsg

        Batches pageModel ->
            Views.Batches.view pageModel
                |> Html.map BatchesMsg

        CreateBatch pageModel ->
            Pages.CreateBatch.view pageModel
                |> Html.map CreateBatchMsg

        Login pageModel ->
            Views.Login.view pageModel

        Users pageModel ->
            Views.Users.view pageModel


header : Model -> Html Msg
header model =
    div [ class "tm-navbar-container" ]
        [ nav [ class "uk-navbar-container tm-navbar-container uk-container", attribute "uk-navbar" "" ]
            [ div [ class "uk-navbar-left" ]
                [ a
                    [ class "uk-logo uk-navbar-item"
                    , href Routes.Home
                    ]
                    [ text "EasyINS" ]
                , viewLinks model.session
                ]
            , div [ class "uk-navbar-right" ]
                [ ul [ class "uk-navbar-nav" ]
                    [ viewAuth model.session
                    ]
                ]
            ]
        ]


viewLinks : Maybe Session -> Html Msg
viewLinks maybeSession =
    case maybeSession of
        Just session ->
            ul [ class "uk-navbar-nav" ]
                [ a
                    [ class "uk-navbar-item"
                    , href Routes.Groups
                    ]
                    [ text "Groups" ]
                , a
                    [ class "uk-navbar-item"
                    , href Routes.Batches
                    ]
                    [ text "Batches" ]
                , a
                    [ class "uk-navbar-item"
                    , href Routes.Users
                    ]
                    [ text "Users" ]
                ]

        Nothing ->
            ul [ class "uk-navbar-nav" ] []


viewAuth : Maybe Session -> Html Msg
viewAuth maybeSession =
    case maybeSession of
        Just session ->
            a
                [ class "uk-navbar-item"
                , onClick LogoutRequest
                ]
                [ text "Logout" ]

        Nothing ->
            a
                [ class "uk-navbar-item"
                , href Routes.Login
                ]
                [ text "Login" ]


debugFooter : Model -> Html Msg
debugFooter model =
    code
        [ style "white-space" "normal" ]
        [ text (Debug.toString model)
        ]


footer : Model -> Html Msg
footer model =
    div [] []
