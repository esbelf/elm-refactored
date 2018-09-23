module Update exposing (update)

import Model exposing (Model, getPage, PageState(..))
import Msg exposing (..)
import Route exposing (updateRoute, parseLocation, setRoute)

import Page exposing (..)
import Pages.Posts
import Pages.Login

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  let
    page = (getPage model.pageState)
    session = model.session
  in
    case (msg, page) of
      ( SetRoute route, _ ) ->
        setRoute route model
      ( HomeMsg, _ ) ->
        ({ model | pageState = Loaded Home }, Cmd.none)

      ( LoginMsg subMsg, Login subModel ) ->
        let
          (newSubModel, newSubMsg) = Pages.Login.update subMsg subModel
          msg = Cmd.map transformLoginMsg newSubMsg
        in
          ({ model | pageState = Loaded (Login newSubModel) }, msg)
      ( LoginLoaded (Ok subModel), _ ) ->
        ({ model | pageState = Loaded (Login subModel) }, Cmd.none)
      ( LoginLoaded (Err error), _ ) ->
        ({ model | pageState = Loaded Blank }, Cmd.none)

      ( PostsMsg subMsg, Posts subModel) ->
        let
          (newSubModel, newSubMsg) = Pages.Posts.update subMsg subModel
          msg = Cmd.map transformPostMsg newSubMsg
        in
          ({ model | pageState = Loaded (Posts newSubModel) }, msg)
      ( PostsLoaded (Ok subModel), _ ) ->
        ({ model | pageState = Loaded (Posts subModel) },  Cmd.none)
      ( PostsLoaded (Err error), _ ) ->
        ({ model | pageState = Loaded Blank }, Cmd.none)
        -- ({ model | pageState = Loaded (Errored error) }, Cmd.none)
      (_, _) ->
        (model, Cmd.none)


transformPostMsg : Pages.Posts.Msg -> Msg
transformPostMsg subMsg =
  PostsMsg subMsg

transformLoginMsg : Pages.Login.Msg -> Msg
transformLoginMsg subMsg =
  LoginMsg subMsg

--transformMsg : Msg -> a -> Cmd Msg
--transformMsg mainMsg subMsg =
--  Cmd.map transformMsgHelper subMsg

--transformMsgHelper : a -> b
--transformMsgHelper a
