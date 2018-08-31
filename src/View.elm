module View exposing(view)

import Page exposing (..)
import Msg exposing (..)
import Model exposing (Model)
--import Pages.Posts
--import Pages.Login

import Html exposing (..)
import Html.Attributes exposing (attribute, class, href)

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
    page = model.currentPage
    session = model.session
  in
  case page of
    Blank ->
      text "Blank Page"

    Posts pageModel ->
      text "Posts Page"

    Login pageModel ->
      text "Login Page"


header : Model -> Html Msg
header model =
    nav [ class "uk-navbar-container tm-navbar-container uk-container", attribute "uk-navbar" ""]
      [ div [ class "uk-navbar-left"]
        [ a [ href ""
          , class "uk-logo uk-navbar-item"
          ] [ text "IMS.app" ]
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
    [ a [ href ""
      , class "uk-navbar-item" ] [ text "Users" ]
    , a [ href ""
      , class "uk-navbar-item" ] [ text "Posts" ]
    ]

footer : Html Msg
footer =
  div [] []
