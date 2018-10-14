module Update exposing (update)

import Helper exposing (..)
import Model exposing (Model, PageState(..), getPage)
import Models.Session
import Msg exposing (..)
import Page exposing (..)
import Pages.Batches
import Pages.Group
import Pages.Groups
import Pages.Login
import Pages.Users
import Port
import Route exposing (parseLocation, setRoute, updateRoute)
import Routes
import Time exposing (Time)
import Time.DateTime as DateTime


updateWith : (subModel -> Page) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toPage toMsg model ( subModel, subCmd ) =
    ( { model | pageState = Loaded (toPage subModel) }
    , Cmd.map toMsg subCmd
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        page =
            getPage model.pageState

        requireSessionOrError callback =
            case model.session of
                Just session ->
                    callback session

                Nothing ->
                    pageErrored model
    in
    case ( msg, page ) of
        ( TimeTick now, _ ) ->
            ( { model | currentTime = DateTime.fromTimestamp now }, Cmd.none )

        ( SetRoute route, _ ) ->
            ( model, updateRoute route )

        ( RouteChanged route, _ ) ->
            setRoute route model

        -- Route.Groups
        ( GroupsMsg subMsg, Groups subModel ) ->
            requireSessionOrError
                (\session ->
                    Pages.Groups.update subMsg subModel session.token
                        |> updateWith Groups GroupsMsg model
                )

        ( GroupsLoaded (Ok subModel), _ ) ->
            ( { model | pageState = Loaded (Groups subModel) }, Cmd.none )

        ( GroupsLoaded (Err error), _ ) ->
            ( { model | pageState = Loaded Blank }, Cmd.none )

        -- Route.Group
        ( GroupMsg subMsg, Group subModel ) ->
            requireSessionOrError
                (\session ->
                    Pages.Group.update subMsg subModel session.token
                        |> updateWith Group GroupMsg model
                )

        ( GroupLoaded (Ok subModel), _ ) ->
            ( { model | pageState = Loaded (Group subModel) }, Cmd.none )

        ( GroupLoaded (Err error), _ ) ->
            ( { model | pageState = Loaded Blank }, Cmd.none )

        ( BatchesMsg subMsg, Batches subModel ) ->
            requireSessionOrError
                (\session ->
                    Pages.Batches.update subMsg subModel session.token
                        |> updateWith Batches BatchesMsg model
                )

        ( BatchesLoaded (Ok subModel), _ ) ->
            ( { model | pageState = Loaded (Batches subModel) }, Cmd.none )

        ( BatchesLoaded (Err error), _ ) ->
            ( { model | pageState = Loaded Blank }, Cmd.none )

        -- Route.Login
        ( LoginMsg subMsg, Login subModel ) ->
            let
                ( newSubModel, newSubMsg ) =
                    Pages.Login.update subMsg subModel

                msg =
                    Cmd.map LoginMsg newSubMsg

                session =
                    newSubModel.session
            in
            ( { model
                | pageState = Loaded (Login newSubModel)
                , session = session
              }
            , msg
            )

        ( LogoutRequest, _ ) ->
            ( { model | session = Nothing }
            , Cmd.batch
                [ Port.removeStorage ()
                , updateRoute Routes.Login
                ]
            )

        -- Route.Users
        ( UsersMsg subMsg, Users subModel ) ->
            requireSessionOrError
                (\session ->
                    Pages.Users.update subMsg subModel session.token
                        |> updateWith Users UsersMsg model
                )

        ( UsersLoaded (Ok subModel), _ ) ->
            ( { model | pageState = Loaded (Users subModel) }, Cmd.none )

        ( UsersLoaded (Err error), _ ) ->
            ( { model | pageState = Loaded Blank }, Cmd.none )

        -- Catch All for now
        ( _, _ ) ->
            ( model, Cmd.none )
