module Update exposing (update)

import Helper exposing (..)
import Model exposing (Model, PageState(..), getPage)
import Msg exposing (..)
import Page exposing (..)
import Pages.Batches
import Pages.CreateBatch
import Pages.CreateGroup
import Pages.EditGroup
import Pages.Groups
import Pages.Login
import Pages.Users
import Port
import Route exposing (parseLocation, setRoute, updateRoute)
import Routes
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

        -- Route.EditGroup
        ( EditGroupMsg subMsg, EditGroup subModel ) ->
            requireSessionOrError
                (\session ->
                    Pages.EditGroup.update subMsg subModel session.token
                        |> updateWith EditGroup EditGroupMsg model
                )

        ( EditGroupLoaded (Ok subModel), _ ) ->
            ( { model | pageState = Loaded (EditGroup subModel) }, Cmd.none )

        ( EditGroupLoaded (Err error), _ ) ->
            ( { model | pageState = Loaded Blank }, Cmd.none )

        -- Routes.CreateGroup
        ( CreateGroupMsg subMsg, CreateGroup subModel ) ->
            requireSessionOrError
                (\session ->
                    Pages.CreateGroup.update subMsg subModel session.token
                        |> updateWith CreateGroup CreateGroupMsg model
                )

        ( CreateGroupLoaded (Ok subModel), _ ) ->
            ( { model | pageState = Loaded (CreateGroup subModel) }, Cmd.none )

        ( CreateGroupLoaded (Err error), _ ) ->
            ( { model | pageState = Loaded Blank }, Cmd.none )

        -- Route.Batches
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

        -- Route.CreateBatch
        ( CreateBatchMsg subMsg, CreateBatch subModel ) ->
            requireSessionOrError
                (\session ->
                    Pages.CreateBatch.update subMsg subModel session.token
                        |> updateWith CreateBatch CreateBatchMsg model
                )

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
            let
                _ =
                    Debug.log "Fell through update. Msg" msg

                _ =
                    Debug.log "Fell through update. Page" page
            in
            ( model, Cmd.none )
