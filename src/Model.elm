module Model exposing (Model, PageState(..), getPage, init)

import Browser.Navigation as Navigation
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
    , navKey : Navigation.Key
    }


initialPage : Page
initialPage =
    Page.Blank


init : Maybe Session -> Int -> Navigation.Key -> Model
init session now navKey =
    { pageState = Loaded initialPage
    , session = session
    , currentTime = Time.millisToPosix now
    , navKey = navKey
    }


getPage : PageState -> Page
getPage pageState =
    case pageState of
        Loaded page ->
            page

        TransitioningFrom page ->
            page
