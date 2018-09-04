module Update exposing (update)

import Model exposing (Model)
import Msg exposing (..)
import Route exposing (routeToPage, updateRoute, parseLocation)

import Page exposing (..)
import Pages.Posts


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    -- Page is reloaded
    NewLocation location ->
      let
        newPage =
          routeToPage (parseLocation location)
      in
        { model | currentPage = newPage } ! []

    -- When page is not reloaded
    NewRoute route ->
      let
        newPage = routeToPage route
      in
        if model.currentPage == newPage then
          (model, Cmd.none)
        else
          ({ model | currentPage = newPage }
          , Cmd.none)
    _ ->
      updatePage msg model

updatePage : Msg -> Model -> (Model, Cmd Msg)
updatePage msg model =
  case ( msg, model.currentPage ) of
    (PostsMsg pageMsg, Posts pageModel) ->
      ({ model | currentPage = Posts (Pages.Posts.update pageMsg pageModel)
      }, Cmd.none)

    (LoginMsg pageMsg, Login pageModel) ->
      (model, Cmd.none)

    (_, _) ->
      (model, Cmd.none)


