module Msg exposing (..)

import Routes exposing (Route)
import Http

import Pages.Login
import Pages.Users
import Pages.Groups
import Pages.Group
import Pages.Batches

type Msg
  = SetRoute Route
  | RouteChanged Route
  | LogoutRequest
  | HomeMsg
  | GroupsLoaded (Result Http.Error (Pages.Groups.Model))
  | GroupsMsg Pages.Groups.Msg
  | GroupLoaded (Result Http.Error (Pages.Group.Model))
  | GroupMsg Pages.Group.Msg
  | BatchesLoaded (Result Http.Error (Pages.Batches.Model))
  | LoginMsg Pages.Login.Msg
  | UsersLoaded (Result Http.Error (Pages.Users.Model))
  | UsersMsg Pages.Users.Msg
  | FileRequest Int (Result Http.Error String)

