module Model exposing (Model, init, PageState(..), getPage)

import Page exposing (Page)

type PageState
    = Loaded Page
    | TransitioningFrom Page

type alias Model =
  { session : String
  , pageState : PageState
  }

initialPage : Page
initialPage =
    Page.Blank

init : String -> Model
init session =
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
