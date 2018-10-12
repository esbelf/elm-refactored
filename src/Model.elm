module Model exposing (Model, PageState(..), getPage, init)

import Debug
import Models.Session exposing (Session)
import Page exposing (Page)
import Time.DateTime as DateTime exposing (DateTime)


type PageState
    = Loaded Page
    | TransitioningFrom Page


type alias Model =
    { session : Maybe Session
    , pageState : PageState
    , currentTime : DateTime
    }


initialPage : Page
initialPage =
    Page.Blank


init : Maybe Session -> Float -> Model
init session now =
    { pageState = Loaded initialPage
    , session = session
    , currentTime = DateTime.fromTimestamp now
    }


getPage : PageState -> Page
getPage pageState =
    case pageState of
        Loaded page ->
            page

        TransitioningFrom page ->
            page
