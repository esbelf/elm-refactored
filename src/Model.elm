module Model exposing (Model, PageState(..), getPage, init)

import Models.Session exposing (Session)
import Page exposing (Page)
import Time exposing (Posix)


type PageState
    = Loaded Page
    | TransitioningFrom Page


type alias Model =
    { session : Maybe Session
    , pageState : PageState
    , currentTime : Posix
    }


initialPage : Page
initialPage =
    Page.Blank


init : Maybe Session -> Int -> Model
init session now =
    { pageState = Loaded initialPage
    , session = session
    , currentTime = Time.millisToPosix now
    }


getPage : PageState -> Page
getPage pageState =
    case pageState of
        Loaded page ->
            page

        TransitioningFrom page ->
            page
