module Views.Posts exposing (view)

import Msg exposing (..)
import Pages.Posts exposing (Model)
import Models.Post exposing (Post)

import Html exposing (..)
-- import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (attribute, class, href, name, type_, value, placeholder)
-- import RemoteData exposing (WebData)

view : Model -> Html Msg
view model =
  div [] [ h1 [] [ text "Posts Page" ]
    , div []
      [ text "okay" ]
    , viewAddPost model
  ]

--viewPostList : WebData (List Post) -> Html Msg
--viewPostList response =
--  case response of
--    RemoteData.NotAsked ->
--      text ""
--    RemoteData.Loading ->
--      text "Loading ..."
--    RemoteData.Success posts ->
--      text "Loaded"
--      -- List.map viewPost posts
--    RemoteData.Failure error ->
--      text (toString error)

viewPost : Post -> Html Msg
viewPost post =
  div [ class "uk-card uk-card-default uk-card-body uk-margin-small" ]
    [ h3 [ class "uk-card-title" ]
      [ text post.title ]
    , p []
      [ text post.description ]
    ]

viewAddPost : Model -> Html Msg
viewAddPost model =
  div [ class "uk-card uk-card-primary uk-card-body" ]
    [ input [ class "uk-input uk-margin-small"
      , name "title"
      , type_ "input"
      , value model.newPostTitle
      , placeholder "Title"
      ] []
    , input [ class "uk-input uk-margin-small"
      , name "description"
      , type_ "input"
      , value model.newPostDescription
      , placeholder "Description"
      ] []
    , button [ class "uk-button uk-button-primary uk-margin-small"
      , type_ "button"
      ] [ text "Add New Post" ]
    ]
