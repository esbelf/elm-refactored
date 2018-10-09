module Msg exposing (Msg(..))

import Http
import Pages.Batches
import Pages.Group
import Pages.Groups
import Pages.Login
import Pages.Users
import Routes exposing (Route)


type Msg
    = SetRoute Route
    | RouteChanged Route
    | LogoutRequest
    | HomeMsg
    | GroupsLoaded (Result Http.Error Pages.Groups.Model)
    | GroupsMsg Pages.Groups.Msg
    | GroupLoaded (Result Http.Error Pages.Group.Model)
    | GroupMsg Pages.Group.Msg
    | BatchesLoaded (Result Http.Error Pages.Batches.Model)
    | BatchesMsg Pages.Batches.Msg
    | BathesLoaded (Result Http.Error Pages.Batches.Model)
    | LoginMsg Pages.Login.Msg
    | UsersLoaded (Result Http.Error Pages.Users.Model)
    | UsersMsg Pages.Users.Msg
    | BatchFormRequest Int (Result Http.Error String)
    | TimeTick Time
