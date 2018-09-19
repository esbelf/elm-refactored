module View exposing(view)

import Page exposing (..)
import Msg exposing (..)
import Model exposing (Model, getPage)
import Route exposing (onClickRoute)
import Routes exposing (Route)

import Html exposing (..)
import Html.Attributes exposing (attribute, class, href)

import Views.Posts

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
  in
  case page of
    Blank ->
      text "Blank Page"

    Home ->
      text "Home Page"

    Posts pageModel ->
      Views.Posts.view pageModel

    Login pageModel ->
      text "Login Page"


header : Model -> Html Msg
header model =
    nav [ class "uk-navbar-container tm-navbar-container uk-container", attribute "uk-navbar" ""]
      [ div [ class "uk-navbar-left"]
        [ a ([ class "uk-logo uk-navbar-item" ] ++ onClickRoute Routes.Home)
          [ text "IMS.app" ]
        , viewLinks
        ]
      , div [ class "uk-navbar-right" ]
        [ ul [ class "uk-navbar-nav" ]
          [ a [ href ""
            , class "uk-navbar-item"
            ]
            [ text "Profile" ]
          , a [ href ""
            , class "uk-navbar-item"
            ]
            [ text "Log Out" ]
          ]
        ]
      ]

viewLinks : Html Msg
viewLinks =
  ul [ class "uk-navbar-nav"]
    [ a ([ class "uk-navbar-item" ] ++ onClickRoute Routes.Posts)
      [ text "Posts" ]
    , a ([ class "uk-navbar-item" ] ++ onClickRoute Routes.Login)
      [ text "Login" ]
    ]

footer : Html Msg
footer =
  div [] []
