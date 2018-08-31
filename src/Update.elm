module Update exposing (update)

import Model exposing (Model)
import Msg exposing (..)

import Page exposing (..)
import Pages.Posts
--import Pages.Login

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  let
    page = model.currentPage
    session = model.session
  in
  case ( msg, page ) of
    (PostsMsg pageMsg, Posts pageModel) ->
      ({ model | currentPage = Posts (Pages.Posts.update pageMsg pageModel)
      }, Cmd.none)

    (LoginMsg pageMsg, Login pageModel) ->
      (model, Cmd.none)

    (_, _) ->
      (model, Cmd.none)
