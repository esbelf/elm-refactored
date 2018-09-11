module Update exposing (update)

import Debug

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
        _ = Debug.log "newPage" newPage
        _ = Debug.log "currentPage" model.currentPage
      in
        if model.currentPage == newPage then
          (model, Cmd.none)
        else
          ({ model | currentPage = newPage }
          , Cmd.none)
    _ ->
      updatePage msg model

updatePage : Msg -> Model -> Model
updatePage msg model =
  case ( msg, model.currentPage ) of
    (PostsMsg pageMsg, Posts pageModel) ->
      let
        newPageModel, nextPageMsg = Pages.Posts.update pageMsg pageModel
        case nextPageMsg of
          Nothing ->
            pageMsg = Nothing
          Just nextPageMsg ->
            pageMsg = PostsMsg nextPageMsg
      in
        ({ model | currentPage = Posts newPageModel
        }, pageMsg)

    (LoginMsg pageMsg, Login pageModel) ->
      (model, Cmd.none)

    (_, _) ->
      (model, Cmd.none)


