module View exposing(view)

import Debug
import Page exposing (..)
import Msg exposing (..)
import Model exposing (Model, getPage)
import Route exposing (onClickRoute)
import Routes exposing (Route)

import Html exposing (..)
import Html.Attributes exposing (attribute, class, href)

import Views.Login
import Views.Users
import Views.Groups
import Views.Group

view : Model -> Html Msg
view model =
  div [ ]
    [ header model
    , div [ class "uk-container" ]
      [ mainContent model ]
    , footer
  ]

mainContent : Model -> Html Msg
mainContent model =
  let
    page = getPage model.pageState
    session = model.session
    log = Debug.log "Error " page
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

    Group pageModel ->
      Views.Group.view pageModel

    Login pageModel ->
      Views.Login.view pageModel

    Users pageModel ->
      Views.Users.view pageModel


header : Model -> Html Msg
header model =
    nav [ class "uk-navbar-container tm-navbar-container uk-container", attribute "uk-navbar" ""]
      [ div [ class "uk-navbar-left"]
        [ a ([ class "uk-logo uk-navbar-item" ] ++ onClickRoute Routes.Home)
          [ text "EasyINS" ]
        , viewLinks
        ]
      , div [ class "uk-navbar-right" ]
        [ ul [ class "uk-navbar-nav" ]
          [ a [ href ""
            , class "uk-navbar-item"
            ]
            [ text "Profile" ]
          , a ([ class "uk-navbar-item" ] ++ onClickRoute Routes.Logout)
            [ text "Logout" ]
          ]
        ]
      ]

viewLinks : Html Msg
viewLinks =
  ul [ class "uk-navbar-nav"]
    [ a ([ class "uk-navbar-item" ] ++ onClickRoute Routes.Groups)
      [ text "Groups" ]
    , a ([ class "uk-navbar-item" ] ++ onClickRoute Routes.Users)
      [ text "Users" ]
    , a ([ class "uk-navbar-item" ] ++ onClickRoute Routes.Login)
      [ text "Login" ]
    ]

footer : Html Msg
footer =
  div [] []
