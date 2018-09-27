module Route exposing (urlChange, setRoute, parseLocation, routeToUrl, onClickRoute, updateRoute)

import Navigation exposing(Location)
import UrlParser exposing (..)

import Html exposing (Html)
import Html.Events exposing (onWithOptions, defaultOptions)
import Html.Attributes exposing (style, href, attribute)
import Json.Decode exposing (Decoder)
import Task exposing (Task)

import Msg exposing (..)
import Model exposing (PageState(..), Model)
import Routes exposing (Route)
import Page

import Pages.Groups
import Pages.Group
import Pages.Posts
import Pages.Login
import Pages.Users

setRoute : Routes.Route -> Model -> ( Model, Cmd Msg )
setRoute route model =
  case route of
    Routes.NotFound ->
      (model, Cmd.none)

    Routes.Home ->
      ({ model | pageState = Loaded Page.Home }, Cmd.none)

    Routes.Groups ->
      let
        token = model.session
        msg = Pages.Groups.init token
          |> Task.attempt GroupsLoaded
      in
        ({ model | pageState = Loaded (Page.Groups Pages.Groups.initialModel) }, msg)

    Routes.Group groupId ->
      let
        token = model.session
        msg = Pages.Group.init groupId token
          |> Task.attempt GroupLoaded
      in
        ({ model | pageState = Loaded (Page.Group Pages.Group.initialModel) }, msg)

    Routes.Posts ->
      let
        token = model.session
        msg = Pages.Posts.init token
          |> Task.attempt PostsLoaded
      in
        ({ model | pageState = Loaded (Page.Posts Pages.Posts.initialModel) }, msg)

    Routes.Login ->
      ({ model | pageState = Loaded (Page.Login Pages.Login.initialModel) }, Cmd.none)

    Routes.Users ->
      let
        token = model.session
        msg = Pages.Users.init token
          |> Task.attempt UsersLoaded
      in
        ({ model | pageState = Loaded (Page.Users Pages.Users.initialModel) }, msg)

urlChange : Location -> Msg
urlChange location =
  let
    route = parseLocation location
  in
    SetRoute route

routeParser : Parser ( Route -> a ) a
routeParser =
  oneOf
    [ map Routes.Home top
    , map Routes.Groups (s ( routeToUrl Routes.Groups ))
    , map Routes.Group (s ( routeToUrl Routes.Groups ) </> int)
    , map Routes.Posts (s ( routeToUrl Routes.Posts ))
    , map Routes.Users (s ( routeToUrl Routes.Users ))
    , map Routes.Login (s ( routeToUrl Routes.Login ))
    ]

parseLocation : Location -> Routes.Route
parseLocation location =
  case (parsePath routeParser location) of
    Just route ->
      route
    Nothing ->
      Routes.NotFound

routeToUrl : Routes.Route -> String
routeToUrl route =
  case route of
    Routes.Home ->
      ""
    Routes.Groups ->
      "groups"
    Routes.Group _ ->
      "groups"
    Routes.Posts ->
      "posts"
    Routes.Users ->
      "users"
    Routes.Login ->
      "login"
    Routes.NotFound ->
      "not-found"



updateRoute : Routes.Route -> Cmd Msg
updateRoute route =
  Navigation.newUrl (routeToUrl route)

-- VIEW HELPERS ---


onClickRoute : Routes.Route -> List (Html.Attribute Msg)
onClickRoute route =
    [ style [ ( "pointer", "cursor" ) ]
    , href (routeToUrl route)
    , onPreventDefaultClick (SetRoute route)
    ]


onPreventDefaultClick : msg -> Html.Attribute msg
onPreventDefaultClick message =
    onWithOptions "click"
        { defaultOptions | preventDefault = True }
        (preventDefault2
            |> Json.Decode.andThen (maybePreventDefault message)
        )


preventDefault2 : Decoder Bool
preventDefault2 =
    Json.Decode.map2
        (invertedOr)
        (Json.Decode.field "ctrlKey" Json.Decode.bool)
        (Json.Decode.field "metaKey" Json.Decode.bool)


maybePreventDefault : msg -> Bool -> Decoder msg
maybePreventDefault msg preventDefault =
    case preventDefault of
        True ->
            Json.Decode.succeed msg

        False ->
            Json.Decode.fail "Normal link"


invertedOr : Bool -> Bool -> Bool
invertedOr x y =
    not (x || y)
