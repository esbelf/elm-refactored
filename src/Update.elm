module Update exposing (update)

import Browser
import Browser.Navigation as Nav
import Helper exposing (..)
import Model exposing (Model, PageState(..), getPage)
import Msg exposing (..)
import Page exposing (..)
import Pages.Batches
import Pages.CreateBatch
import Pages.GroupForm
import Pages.Groups
import Pages.Login
import Pages.Users
import Port
import Route exposing (setRoute, updateRoute)
import Routes
import Url


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
            ( { model | currentTime = now }, Cmd.none )

        ( SetRoute route, _ ) ->
            ( model, updateRoute model.navKey route )

        ( RouteChanged route, _ ) ->
            setRoute route model

        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                      -- may need to add more logic here??
                    , Nav.pushUrl model.navKey (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                      -- probably want to send this to "open in new tab port" - does this simplify the preview links/commands?
                    , Nav.load href
                    )

        ( GroupsMsg subMsg, Groups subModel ) ->
            requireSessionOrError
                (\session ->
                    Pages.Groups.update subMsg subModel session.token
                        |> updateWith Groups GroupsMsg model
                )

        ( EditGroupMsg subMsg, EditGroup subModel ) ->
            requireSessionOrError
                (\session ->
                    Pages.GroupForm.update subMsg subModel session.token
                        |> updateWith EditGroup EditGroupMsg model
                )

        ( CreateGroupMsg subMsg, CreateGroup subModel ) ->
            requireSessionOrError
                (\session ->
                    Pages.GroupForm.update subMsg subModel session.token
                        |> updateWith CreateGroup CreateGroupMsg model
                )

        ( BatchesMsg subMsg, Batches subModel ) ->
            requireSessionOrError
                (\session ->
                    Pages.Batches.update subMsg subModel session.token
                        |> updateWith Batches BatchesMsg model
                )

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

                mappedMsg =
                    Cmd.map LoginMsg newSubMsg

                session =
                    newSubModel.session
            in
            ( { model
                | pageState = Loaded (Login newSubModel)
                , session = session
              }
            , mappedMsg
            )

        ( LogoutRequest, _ ) ->
            ( { model | session = Nothing }
            , Cmd.batch
                [ Port.removeStorage ()
                , updateRoute model.navKey Routes.Login
                ]
            )

        -- Route.Users
        ( UsersMsg subMsg, Users subModel ) ->
            requireSessionOrError
                (\session ->
                    Pages.Users.update subMsg subModel session.token
                        |> updateWith Users UsersMsg model
                )

        -- Catch All for now
        ( _, _ ) ->
            let
                _ =
                    Debug.log "Fell through update. Msg" msg

                _ =
                    Debug.log "Fell through update. Page" page
            in
            ( model, Cmd.none )
