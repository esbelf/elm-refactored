module Route exposing (onClickRoute, parseLocation, routeToUrl, setRoute, updateRoute, urlChange)

import Debug
import Helper exposing (pageErrored)
import Html exposing (Html)
import Html.Attributes exposing (attribute, href, style)
import Html.Events exposing (defaultOptions, onWithOptions)
import Json.Decode exposing (Decoder)
import Model exposing (Model, PageState(..))
import Models.Session
import Msg exposing (..)
import Navigation exposing (Location)
import Page
import Pages.Batches
import Pages.Group
import Pages.Groups
import Pages.Login
import Pages.Users
import Port
import Routes exposing (Route)
import Task exposing (Task)
import UrlParser exposing (..)


setRoute : Routes.Route -> Model -> ( Model, Cmd Msg )
setRoute route model =
    let
        checkedSession =
            Models.Session.checkSessionValidity model.session model.currentTime
    in
    case ( route, checkedSession ) of
        ( Routes.NotFound, _ ) ->
            ( model, Cmd.none )

        ( Routes.Home, _ ) ->
            ( { model | pageState = Loaded Page.Home }, Cmd.none )

        ( Routes.Login, _ ) ->
            ( { model | pageState = Loaded (Page.Login Pages.Login.initialModel) }, Cmd.none )

        ( Routes.Logout, _ ) ->
            ( { model | session = Nothing }
            , Cmd.batch
                [ Port.removeStorage ()
                , updateRoute Routes.Login
                ]
            )

        ( Routes.Groups, Just session ) ->
            let
                msg =
                    Pages.Groups.init session.token
                        |> Task.attempt GroupsLoaded
            in
            ( { model | pageState = Loaded (Page.Groups Pages.Groups.initialModel) }, msg )

        ( Routes.Group groupId, Just session ) ->
            let
                msg =
                    Pages.Group.init groupId session.token
                        |> Task.attempt GroupLoaded
            in
            ( { model | pageState = Loaded (Page.Group Pages.Group.initialModel) }, msg )

        ( Routes.Batches, Just session ) ->
            let
                msg =
                    Pages.Batches.init session.token
                        |> Task.attempt BatchesLoaded
            in
            ( { model | pageState = Loaded (Page.Batches Pages.Batches.initialModel) }, msg )

        ( Routes.Users, Just session ) ->
            let
                msg =
                    Pages.Users.init session.token
                        |> Task.attempt UsersLoaded
            in
            ( { model | pageState = Loaded (Page.Users Pages.Users.initialModel) }, msg )

        ( _, _ ) ->
            pageErrored model


urlChange : Location -> Msg
urlChange location =
    let
        route =
            parseLocation location
    in
    RouteChanged route


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ map Routes.Home top
        , map Routes.Groups (s (routeToUrl Routes.Groups))
        , map Routes.Group (s (routeToUrl Routes.Groups) </> int)
        , map Routes.Batches (s (routeToUrl Routes.Batches))
        , map Routes.Users (s (routeToUrl Routes.Users))
        , map Routes.Login (s (routeToUrl Routes.Login))
        ]


parseLocation : Location -> Routes.Route
parseLocation location =
    case parsePath routeParser location of
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

        Routes.Group id ->
            "groups/" ++ toString id

        Routes.Batches ->
            "batches"

        Routes.Users ->
            "users"

        Routes.Login ->
            "login"

        Routes.Logout ->
            "logout"

        Routes.NotFound ->
            "not-found"


updateRoute : Routes.Route -> Cmd Msg
updateRoute route =
    Navigation.newUrl ("/" ++ routeToUrl route)



-- VIEW HELPERS ---


onClickRoute : Routes.Route -> List (Html.Attribute Msg)
onClickRoute route =
    [ style [ ( "pointer", "cursor" ) ]
    , href (baseUrl ++ routeToUrl route)
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
        invertedOr
        (Json.Decode.field "ctrlKey" Json.Decode.bool)
        (Json.Decode.field "metaKey" Json.Decode.bool)


maybePreventDefault : msg -> Bool -> Decoder msg
maybePreventDefault msg preventDefault =
    case preventDefault of
        True ->
            Json.Decode.succeed msg

        False ->
            Json.Decode.fail "Normal link"


baseUrl : String
baseUrl =
    "http://easyins.s3-website-us-east-1.amazonaws.com"


invertedOr : Bool -> Bool -> Bool
invertedOr x y =
    not (x || y)
