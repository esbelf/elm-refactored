module Views.Posts exposing (view)

import Msg exposing (..)
import Pages.Posts exposing (Model)
import Models.Post exposing (Post)

import Html exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (attribute, class, href, name, type_, value, placeholder)

view : Model -> Html Msg
view model =
  div [] [ h1 [] [ text "Posts Page" ]
    , div []
      (viewPostList model.posts)
    , viewAddPost model
  ]

viewPostList : List Post -> List (Html Msg)
viewPostList posts =
  List.map viewPost posts

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
      , onInput (PostsMsg << Pages.Posts.SetPostTitle)
      ] []
    , input [ class "uk-input uk-margin-small"
      , name "description"
      , type_ "input"
      , value model.newPostDescription
      , placeholder "Description"
      , onInput (PostsMsg << Pages.Posts.SetPostDescription)
      ] []
    , button [ class "uk-button uk-button-primary uk-margin-small"
      , type_ "button"
      , onClick (PostsMsg Pages.Posts.AddPost)
      ] [ text "Add New Post" ]
    ]
