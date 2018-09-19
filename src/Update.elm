module Update exposing (update)

import Model exposing (Model, getPage, PageState(..))
import Msg exposing (..)
import Route exposing (updateRoute, parseLocation, setRoute)

import Page exposing (..)
import Pages.Posts

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
        (model, Cmd.none)
      --( HomeLoaded (Ok subModel), _ ) ->
      --  (model, Cmd.none)
      --( HomeLoaded (Err error), _ ) ->
      --  (model, Cmd.none)
      ( PostsMsg subMsg, Posts subModel) ->
        let
          (newSubModel, newSubMsg) = Pages.Posts.update subMsg subModel
        in
          ({ model | pageState = Loaded (Posts newSubModel) }, Cmd.none)
      ( PostsLoaded (Ok subModel), _ ) ->
        ({ model | pageState = Loaded (Posts subModel) },  Cmd.none)
      ( PostsLoaded (Err error), _ ) ->
        ({ model | pageState = Loaded Blank }, Cmd.none)
        -- ({ model | pageState = Loaded (Errored error) }, Cmd.none)
      (_, _) ->
        (model, Cmd.none)


  --case msg of
  --  -- Page is reloaded
  --  NewLocation location ->
  --    routeToPage (parseLocation location) model

  --  -- When page is not reloaded
  --  NewRoute route ->
  --    newPage = routeToPage route model
  --  -- _ = Debug.log "newPage" newPage
  --  _ ->
  --    updatePage msg model

--updatePage : Msg -> Model -> Model
--updatePage msg model =
--  case ( msg, model.currentPage ) of
--    (PostsMsg pageMsg, Posts pageModel) ->
--      let
--        newPageModel, nextPageMsg = Pages.Posts.update pageMsg pageModel
--        case nextPageMsg of
--          Nothing ->
--            pageMsg = Nothing
--          Just nextPageMsg ->
--            pageMsg = PostsMsg nextPageMsg
--      in
--        ({ model | currentPage = Posts newPageModel
--        }, pageMsg)

--    (LoginMsg pageMsg, Login pageModel) ->
--      (model, Cmd.none)

--    (_, _) ->
--      (model, Cmd.none)


