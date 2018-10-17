module Update exposing (update)

import Helper exposing (..)
import Model exposing (Model, PageState(..), getPage)
import Models.Session
import Msg exposing (..)
import Page exposing (..)
import Pages.Batches
import Pages.CreateGroup
import Pages.CreateProduct
import Pages.EditGroup
import Pages.EditProduct
import Pages.Groups
import Pages.Login
import Pages.Products
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

        -- Route.Products
        ( ProductsMsg subMsg, Products subModel ) ->
            requireSessionOrError
                (\session ->
                    Pages.Products.update subMsg subModel session.token
                        |> updateWith Products ProductsMsg model
                )

        ( ProductsLoaded (Ok subModel), _ ) ->
            ( { model | pageState = Loaded (Products subModel) }, Cmd.none )

        ( ProductsLoaded (Err error), _ ) ->
            ( { model | pageState = Loaded Blank }, Cmd.none )

        -- Route.EditProduct
        ( EditProductMsg subMsg, EditProduct subModel ) ->
            requireSessionOrError
                (\session ->
                    Pages.EditProduct.update subMsg subModel session.token
                        |> updateWith EditProduct EditProductMsg model
                )

        ( EditProductLoaded (Ok subModel), _ ) ->
            ( { model | pageState = Loaded (EditProduct subModel) }, Cmd.none )

        ( EditProductLoaded (Err error), _ ) ->
            ( { model | pageState = Loaded Blank }, Cmd.none )

        -- Route.CreateProduct
        ( CreateProductMsg subMsg, CreateProduct subModel ) ->
            requireSessionOrError
                (\session ->
                    Pages.CreateProduct.update subMsg subModel session.token
                        |> updateWith CreateProduct CreateProductMsg model
                )

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
