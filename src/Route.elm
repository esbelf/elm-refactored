module Route exposing (fromUrl, onClickRoute, parseUrl, setRoute, updateRoute, urlChange)

import Browser.Navigation as Nav
import Helper exposing (pageErrored)
import Html exposing (Attribute)
import Html.Attributes as Attr
import Html.Events exposing (defaultOptions, onWithOptions)
import Json.Decode exposing (Decoder)
import Model exposing (Model, PageState(..))
import Models.Session
import Msg exposing (..)
import Page
import Pages.Batches
import Pages.CreateBatch
import Pages.CreateGroup
import Pages.EditGroup
import Pages.Groups
import Pages.Login
import Pages.Users
import Port
import Routes exposing (Route)
import Task exposing (Task)
import Url exposing (Url)
import Url.Parser as Parser exposing ((<=/>), Parser, int, oneOf, s, string)


setRoute : Route -> Model -> ( Model, Cmd Msg )
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

        ( Routes.EditGroup groupId, Just session ) ->
            let
                msg =
                    Pages.EditGroup.init groupId session.token
                        |> Task.attempt EditGroupLoaded
            in
            ( { model | pageState = Loaded (Page.EditGroup Pages.EditGroup.initialModel) }, msg )

        ( Routes.CreateGroup, _ ) ->
            ( { model | pageState = Loaded (Page.CreateGroup Pages.CreateGroup.initialModel) }, Cmd.none )

        ( Routes.Batches, Just session ) ->
            let
                msg =
                    Pages.Batches.init session.token
                        |> Task.attempt BatchesLoaded
            in
            ( { model | pageState = Loaded (Page.Batches Pages.Batches.initialModel) }, msg )

        ( Routes.CreateBatch groupId, Just session ) ->
            let
                subModel =
                    Pages.CreateBatch.initNew session.token groupId
            in
            ( { model | pageState = Loaded (Page.CreateBatch subModel) }, Cmd.none )

        ( Routes.Users, Just session ) ->
            let
                msg =
                    Pages.Users.init session.token
                        |> Task.attempt UsersLoaded
            in
            ( { model | pageState = Loaded (Page.Users Pages.Users.initialModel) }, msg )

        ( _, _ ) ->
            pageErrored model


onUrlChange : Url -> Msg
onUrlChange url =
    let
        route =
            parseLocation url
    in
    RouteChanged route


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ Parser.map Routes.Home Parser.top
        , Parser.map Routes.Groups (s (routeToString Routes.Groups))
        , Parser.map Routes.EditGroup (s (routeToString Routes.Groups) </> int)
        , Parser.map Routes.CreateGroup (s "groups" </> s "new")
        , Parser.map Routes.Batches (s (routeToString Routes.Batches))
        , Parser.map Routes.CreateBatch (s "batches" </> s "new" </> int)
        , Parser.map Routes.Users (s (routeToString Routes.Users))
        , Parser.map Routes.Login (s (routeToString Routes.Login))
        ]


fromUrl : Url -> Route
fromUrl url =
    case parseUrl url of
        Just route ->
            route

        Nothing ->
            Routes.NotFound


parseUrl : Url -> Maybe Route
parseUrl url =
    Parser.parse routeParser


replaceUrl : Nav.Key -> Route -> Cmd Msg
replaceUrl key route =
    -- TODO: make leading slash part of routeToString
    Nav.replaceUrl key ("/" ++ routeToString route)



-- VIEW HELPERS ---


href : Route -> Attribute Msg
href targetRoute =
    Attr.href (routeToString targetRoute)


baseUrl : String
baseUrl =
    "http://easyins.s3-website-us-east-1.amazonaws.com"



-- INTERNAL


routeToString : Route -> String
routeToString route =
    case route of
        Routes.Home ->
            ""

        Routes.Groups ->
            "groups"

        Routes.EditGroup id ->
            "groups/" ++ String.fromInt id

        Routes.CreateGroup ->
            "groups/new"

        Routes.Batches ->
            "batches"

        Routes.CreateBatch id ->
            "batches/new/" ++ String.fromInt id

        Routes.Users ->
            "users"

        Routes.Login ->
            "login"

        Routes.Logout ->
            "logout"

        Routes.NotFound ->
            "not-found"
