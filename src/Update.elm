module Update exposing (update)

import Model exposing (Model, getPage, PageState(..))
import Models.Session
import Msg exposing (..)
import Route exposing (updateRoute, parseLocation, setRoute)
import Routes

import Helper exposing (..)

import Page exposing (..)
import Pages.Users
import Pages.Login
import Pages.Groups
import Pages.Group


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  let
    page = (getPage model.pageState)
    token = model.session.token
  in
    case (msg, page) of
      ( SetRoute route, _ ) ->
        setRoute route model

      -- Route.Home
      ( HomeMsg, _ ) ->
        ({ model | pageState = Loaded Home }, Cmd.none)

      -- Route.Groups
      ( GroupsMsg subMsg, Groups subModel ) ->
        case token of
          Just token ->
            let
              (newSubModel, newSubMsg) = Pages.Groups.update subMsg subModel token
              msg = Cmd.map transformGroupsMsg newSubMsg
            in
              ({ model | pageState = Loaded (Groups newSubModel) }, msg)
          Nothing ->
            pageErrored model

      ( GroupsLoaded (Ok subModel), _ ) ->
        ({ model | pageState = Loaded (Groups subModel) }, Cmd.none)
      ( GroupsLoaded (Err error), _ ) ->
        ({ model | pageState = Loaded Blank }, Cmd.none)

      -- Route.Group
      ( GroupMsg subMsg, Group subModel ) ->
        case token of
          Just token ->
            let
              (newSubModel, newSubMsg) = Pages.Group.update subMsg subModel token
              msg = Cmd.map transformGroupMsg newSubMsg
            in
              ({ model | pageState = Loaded (Group newSubModel) }, msg)
          Nothing ->
            pageErrored model

      ( GroupLoaded (Ok subModel), _ ) ->
        ({ model | pageState = Loaded (Group subModel) }, Cmd.none)

      ( GroupLoaded (Err error), _ ) ->
        ({ model | pageState = Loaded Blank }, Cmd.none)

      -- Route.Login
      ( LoginMsg subMsg, Login subModel ) ->
        let
          (newSubModel, newSubMsg) = Pages.Login.update subMsg subModel
          msg = Cmd.map transformLoginMsg newSubMsg
          session = Models.Session.init newSubModel.token
        in
          ({ model |
            pageState = Loaded (Login newSubModel),
            session = session
          }, msg)

      -- Route.Users
      ( UsersMsg subMsg, Users subModel) ->
        case token of
          Just token ->
            let
              (newSubModel, newSubMsg) = Pages.Users.update subMsg subModel token
              msg = Cmd.map transformUserMsg newSubMsg
            in
              ({ model | pageState = Loaded (Users newSubModel) }, msg)
          Nothing ->
            pageErrored model

      ( UsersLoaded (Ok subModel), _ ) ->
        ({ model | pageState = Loaded (Users subModel) }, Cmd.none)
      ( UsersLoaded (Err error), _ ) ->
        ({ model | pageState = Loaded Blank }, Cmd.none)

      -- Catch All for now
      (_, _) ->
        (model, Cmd.none)


transformLoginMsg : Pages.Login.Msg -> Msg
transformLoginMsg subMsg =
  LoginMsg subMsg

transformUserMsg : Pages.Users.Msg -> Msg
transformUserMsg subMsg =
  UsersMsg subMsg

transformGroupsMsg : Pages.Groups.Msg -> Msg
transformGroupsMsg subMsg =
  GroupsMsg subMsg

transformGroupMsg : Pages.Group.Msg -> Msg
transformGroupMsg subMsg =
  GroupMsg subMsg

--transformMsg : a -> b -> Msg
--transformMsg mainMsg subMsg =
--  Cmd.map (transformMsgHelper mainMsg) subMsg

--transformMsgHelper : String -> Msg
--transformMsgHelper a =
--  a b

--type alias MsgType a =


