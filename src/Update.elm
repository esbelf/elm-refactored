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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        page =
            getPage model.pageState

        token =
            model.session.token
    in
    case ( msg, page ) of
        ( TimeTick now, _ ) ->
            { model | session = Models.Session.updateCurrentTime now }

        ( SetRoute route, _ ) ->
            ( model, updateRoute route )

        ( RouteChanged route, _ ) ->
            setRoute route model

        -- Route.Home
        ( HomeMsg, _ ) ->
            ( { model | pageState = Loaded Home }, Cmd.none )

        -- Route.Groups
        ( GroupsMsg subMsg, Groups subModel ) ->
            if Models.Session.valid model.session then
                let
                    ( newSubModel, newSubMsg ) =
                        Pages.Groups.update subMsg subModel token

                    msg =
                        Cmd.map transformGroupsMsg newSubMsg
                in
                ( { model | pageState = Loaded (Groups newSubModel) }, msg )

            else
                pageErrored model

        ( GroupsLoaded (Ok subModel), _ ) ->
            ( { model | pageState = Loaded (Groups subModel) }, Cmd.none )

        ( GroupsLoaded (Err error), _ ) ->
            ( { model | pageState = Loaded Blank }, Cmd.none )

        -- Route.Group
        ( GroupMsg subMsg, Group subModel ) ->
            if Models.Session.valid model.session then
                let
                    ( newSubModel, newSubMsg ) =
                        Pages.Group.update subMsg subModel token

                    msg =
                        Cmd.map transformGroupMsg newSubMsg
                in
                ( { model | pageState = Loaded (Group newSubModel) }, msg )

            else
                pageErrored model

        ( GroupLoaded (Ok subModel), _ ) ->
            ( { model | pageState = Loaded (Group subModel) }, Cmd.none )

        ( GroupLoaded (Err error), _ ) ->
            ( { model | pageState = Loaded Blank }, Cmd.none )

        ( BatchesMsg subMsg, Batches subModel ) ->
            if Models.Session.valid model.session then
                let
                    ( newSubModel, newSubMsg ) =
                        Pages.Batches.update subMsg subModel token

                    msg =
                        Cmd.map transformBatchesMsg newSubMsg
                in
                ( { model | pageState = Loaded (Batches newSubModel) }, msg )

            else
                pageErrored model

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
                    Cmd.map transformLoginMsg newSubMsg

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
            let
                emptySession =
                    Models.Session.init "" ""
            in
            ( { model | session = emptySession }
            , Cmd.batch
                [ Port.removeStorage ()
                , updateRoute Routes.Login
                ]
            )

        -- Route.Users
        ( UsersMsg subMsg, Users subModel ) ->
            if Models.Session.valid model.session then
                let
                    ( newSubModel, newSubMsg ) =
                        Pages.Users.update subMsg subModel token

                    msg =
                        Cmd.map transformUserMsg newSubMsg
                in
                ( { model | pageState = Loaded (Users newSubModel) }, msg )

            else
                pageErrored model

        ( UsersLoaded (Ok subModel), _ ) ->
            ( { model | pageState = Loaded (Users subModel) }, Cmd.none )

        ( UsersLoaded (Err error), _ ) ->
            ( { model | pageState = Loaded Blank }, Cmd.none )

        -- Catch All for now
        ( _, _ ) ->
            ( model, Cmd.none )


transformLoginMsg : Pages.Login.Msg -> Msg
transformLoginMsg subMsg =
    LoginMsg subMsg


transformUserMsg : Pages.Users.Msg -> Msg
transformUserMsg subMsg =
    UsersMsg subMsg


transformGroupsMsg : Pages.Groups.Msg -> Msg
transformGroupsMsg subMsg =
    GroupsMsg subMsg


transformGroupMsg : Pages.Group.Msg -> Msg
transformGroupMsg subMsg =
    GroupMsg subMsg


transformBatchesMsg : Pages.Batches.Msg -> Msg
transformBatchesMsg subMsg =
    BatchesMsg subMsg



--transformMsg : a -> b -> Msg
--transformMsg mainMsg subMsg =
--  Cmd.map (transformMsgHelper mainMsg) subMsg
--transformMsgHelper : String -> Msg
--transformMsgHelper a =
--  a b
--type alias MsgType a =
