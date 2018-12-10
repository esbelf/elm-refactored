module Msg exposing (Msg(..))

import Browser
import Http
import Pages.Batches
import Pages.CreateBatch
import Pages.GroupForm
import Pages.Groups
import Pages.Login
import Pages.Users
import Routes exposing (Route)
import Time exposing (Posix)


type Msg
    = SetRoute Route
    | RouteChanged Route
    | ClickedLink Browser.UrlRequest
    | LogoutRequest
    | HomeMsg
    | GroupsMsg Pages.Groups.Msg
    | EditGroupMsg Pages.GroupForm.Msg
    | CreateGroupMsg Pages.GroupForm.Msg
    | BatchesMsg Pages.Batches.Msg
    | CreateBatchMsg Pages.CreateBatch.Msg
    | LoginMsg Pages.Login.Msg
    | UsersMsg Pages.Users.Msg
    | BatchFormRequest Int (Result Http.Error String)
    | TimeTick Posix
