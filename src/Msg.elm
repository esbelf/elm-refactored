module Msg exposing (..)

import Navigation exposing(Location)
import Routes exposing (Route)

import Pages.Posts
import Pages.Login

type Msg
  = NewRoute Route
  | NewLocation Location
  | PostsMsg Pages.Posts.Msg
  | LoginMsg Pages.Login.Msg

