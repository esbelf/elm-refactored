module Route exposing (parseLocation, routeToUrl, onClickRoute, updateRoute, routeToPage)

import Navigation exposing(Location)
import UrlParser exposing (..)

import Html exposing (Html)
import Html.Events exposing (onWithOptions, defaultOptions)
import Html.Attributes exposing (style, href, attribute)
import Json.Decode exposing (Decoder)

import Msg exposing (..)
import Routes exposing (Route)
import Page exposing (Page)

import Pages.Posts
import Pages.Login

routeParser : Parser ( Route -> a ) a
routeParser =
  oneOf
    [ map Routes.Home top
    , map Routes.Posts (s ( routeToUrl Routes.Posts ))
    , map Routes.Login (s ( routeToUrl Routes.Login ))
    ]

parseLocation : Location -> Route
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
    Routes.Posts ->
      "posts"
    Routes.Login ->
      "login"
    Routes.NotFound ->
      "not-found"

updateRoute : Routes.Route -> Cmd Msg
updateRoute route =
  Navigation.newUrl (routeToUrl route)

routeToPage : Routes.Route -> Model -> ( Model, Cmd Msg )
routeToPage route =
  case route of
    Routes.Home ->
      Page.Blank

    Routes.Posts ->
      Page.Posts Pages.Posts.init

    Routes.Login ->
      Page.Login Pages.Login.init

    Routes.NotFound ->
      Page.Blank

-- VIEW HELPERS ---


onClickRoute : Routes.Route -> List (Html.Attribute Msg)
onClickRoute route =
    [ style [ ( "pointer", "cursor" ) ]
    , href (routeToUrl route)
    , onPreventDefaultClick (NewRoute route)
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
