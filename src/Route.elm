module Route exposing (fromUrl, onUrlChange, parseUrl, setRoute, updateRoute)

import Browser.Navigation as Nav
import Helper exposing (pageErrored)
import Html exposing (Attribute)
import Html.Attributes as Attr
import Json.Decode exposing (Decoder)
import Model exposing (Model, PageState(..))
import Models.Session
import Msg exposing (..)
import Page
import Pages.Batches
import Pages.CreateBatch
import Pages.GroupForm
import Pages.Groups
import Pages.Login
import Pages.Users
import Port
import Routes exposing (Route)
import Task exposing (Task)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, int, oneOf, s, string)


setRoute : Route -> Model -> ( Model, Cmd Msg )
setRoute newRoute model =
    let
        checkedSession =
            Models.Session.checkSessionValidity model.session model.currentTime

        initializeSubcomponent toSubmodel toSubmsg ( submodel, submsg ) =
            ( { model | pageState = Loaded (toSubmodel submodel) }, Cmd.map toSubmsg submsg )
    in
    case ( newRoute, checkedSession ) of
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
                , updateRoute model.navKey Routes.Login
                ]
            )

        ( Routes.Groups, Just session ) ->
            Pages.Groups.init session.token model.navKey
                |> initializeSubcomponent Page.Groups GroupsMsg

        ( Routes.EditGroup groupId, Just session ) ->
            Pages.GroupForm.init (Just groupId) session.token model.navKey
                |> initializeSubcomponent Page.EditGroup EditGroupMsg

        ( Routes.CreateGroup, Just session ) ->
            Pages.GroupForm.init Nothing session.token model.navKey
                |> initializeSubcomponent Page.CreateGroup CreateGroupMsg

        ( Routes.Batches, Just session ) ->
            Pages.Batches.init session.token
                |> initializeSubcomponent Page.Batches BatchesMsg

        ( Routes.CreateBatch groupId, Just session ) ->
            let
                subModel =
                    Pages.CreateBatch.initNew session.token groupId model.navKey
            in
            ( { model | pageState = Loaded (Page.CreateBatch subModel) }, Cmd.none )

        ( Routes.Users, Just session ) ->
            Pages.Users.init session.token
                |> initializeSubcomponent Page.Users UsersMsg

        ( _, _ ) ->
            pageErrored model


onUrlChange : Url -> Msg
onUrlChange url =
    let
        route =
            parseUrl url
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
parseUrl =
    Parser.parse routeParser


updateRoute : Nav.Key -> Route -> Cmd Msg
updateRoute key route =
    -- TODO: make leading slash part of routeToString
    Nav.replaceUrl key ("/" ++ Routes.routeToString route)



-- VIEW HELPERS (that don't help being in this file, but eventually...) ---


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
