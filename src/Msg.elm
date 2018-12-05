module Msg exposing (Msg(..))

import Http
import Pages.Batches
import Pages.CreateBatch
import Pages.CreateGroup
import Pages.EditGroup
import Pages.Groups
import Pages.Login
import Pages.Users
import Routes exposing (Route)
import Time exposing (Posix)


type Msg
    = SetRoute Route
    | RouteChanged Route
    | LogoutRequest
    | HomeMsg
    | GroupsLoaded (Result Http.Error Pages.Groups.Model)
    | GroupsMsg Pages.Groups.Msg
    | EditGroupLoaded (Result Http.Error Pages.EditGroup.Model)
    | EditGroupMsg Pages.EditGroup.Msg
    | CreateGroupMsg Pages.CreateGroup.Msg
    | CreateGroupLoaded (Result Http.Error Pages.CreateGroup.Model)
    | BatchesLoaded (Result Http.Error Pages.Batches.Model)
    | BatchesMsg Pages.Batches.Msg
    | BathesLoaded (Result Http.Error Pages.Batches.Model)
    | CreateBatchMsg Pages.CreateBatch.Msg
    | LoginMsg Pages.Login.Msg
    | UsersLoaded (Result Http.Error Pages.Users.Model)
    | UsersMsg Pages.Users.Msg
    | BatchFormRequest Int (Result Http.Error String)
    | TimeTick Posix
