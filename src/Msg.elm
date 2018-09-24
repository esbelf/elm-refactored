module Msg exposing (..)

import Routes exposing (Route)
import Http

import Pages.Posts
import Pages.Login
import Pages.Users
import Pages.Groups

type Msg
  = SetRoute Route
  | HomeMsg
  | GroupsLoaded (Result Http.Error (Pages.Groups.Model))
  | GroupsMsg Pages.Groups.Msg
  | PostsLoaded (Result Http.Error (Pages.Posts.Model))
  | PostsMsg Pages.Posts.Msg
  | LoginLoaded (Result Http.Error (Pages.Login.Model))
  | LoginMsg Pages.Login.Msg
  | UsersLoaded (Result Http.Error (Pages.Users.Model))
  | UsersMsg Pages.Users.Msg

