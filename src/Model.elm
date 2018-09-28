module Model exposing (Model, init, PageState(..), getPage)

import Page exposing (Page)
import Models.Session exposing (Session)

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

init : String -> Model
init token =
  let
    session =
      if (String.isEmpty token) then
        { token = Nothing }
      else
        { token = Just token }
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
