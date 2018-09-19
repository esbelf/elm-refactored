module Msg exposing (..)

import Routes exposing (Route)
import Http

import Pages.Posts
import Pages.Login

type Msg
  = HomeMsg
  | PostsLoaded (Result Http.Error (Pages.Posts.Model))
  | PostsMsg Pages.Posts.Msg
  | LoginLoaded (Result Http.Error (Pages.Login.Model))
  | SetRoute Route

