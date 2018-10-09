module Model exposing (Model, PageState(..), getPage, init)

import Debug
import Models.Session exposing (Session)
import Page exposing (Page)


type PageState
    = Loaded Page
    | TransitioningFrom Page


type alias Model =
    { session : Session
    , pageState : PageState
    }


initialPage : Page
initialPage =
    Page.Blank


init : Session -> Model
init session =
    let
        log =
            Debug.log "Model Init" session

        --session =
        --  if (String.isEmpty token) then
        --    { token = Nothing }
        --  else
        --    { token = Just token }
    in
    { pageState = Loaded initialPage
    , session = session
    }


getPage : PageState -> Page
getPage pageState =
    case pageState of
        Loaded page ->
            page

        TransitioningFrom page ->
            page
