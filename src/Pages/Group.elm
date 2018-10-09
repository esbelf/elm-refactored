module Pages.Group exposing (Model, Msg(..), addGroupToModel, init, initialModel, transformProductMsg, update)

import Http
import Models.Group exposing (Group)
import Pages.Product
import Requests.Group
import Task exposing (Task)


type Msg
    = SetName String
    | SetPaymentMode String
    | SetFormType String
    | SetDisclosure String
    | UpdateGroupRequest
    | UpdateGroup (Result Http.Error Group)
    | ProductMsg Pages.Product.Msg


type alias Model =
    { group : Group
    , errorMsg : String
    , id : Int
    , productPageModel : Pages.Product.Model
    }


initialModel : Model
initialModel =
    { group = Models.Group.init
    , errorMsg = ""
    , id = 0
    , productPageModel = Pages.Product.init
    }


init : Int -> String -> Task Http.Error Model
init groupId token =
    Task.map addGroupToModel (Requests.Group.get groupId token)


addGroupToModel : Group -> Model
addGroupToModel group =
    let
        pageProductModel =
            Pages.Product.init

        productPageModel =
            { pageProductModel | products = group.products }
    in
    { initialModel
        | id = group.id
        , group = group
        , productPageModel = productPageModel
    }


update : Msg -> Model -> String -> ( Model, Cmd Msg )
update msg model token =
    case msg of
        SetName name ->
            let
                oldGroup =
                    model.group
            in
            ( { model | group = { oldGroup | name = name } }, Cmd.none )

        SetPaymentMode paymentMode ->
            let
                oldGroup =
                    model.group

                newPaymentMode =
                    String.toInt paymentMode
                        |> Result.toMaybe
                        |> Maybe.withDefault oldGroup.payment_mode
            in
            ( { model | group = { oldGroup | payment_mode = newPaymentMode } }, Cmd.none )

        SetFormType formType ->
            let
                oldGroup =
                    model.group
            in
            ( { model | group = { oldGroup | form_type = formType } }, Cmd.none )

        SetDisclosure disclosure ->
            let
                oldGroup =
                    model.group
            in
            ( { model | group = { oldGroup | disclosure = disclosure } }, Cmd.none )

        UpdateGroupRequest ->
            let
                newMsg =
                    Requests.Group.update model.group token
                        |> Task.attempt UpdateGroup
            in
            ( model, newMsg )

        UpdateGroup (Ok updatedGroup) ->
            ( { model | group = updatedGroup }, Cmd.none )

        UpdateGroup (Err error) ->
            ( { model | errorMsg = toString error }, Cmd.none )

        ProductMsg subMsg ->
            let
                ( newProductPageModel, newSubMsg ) =
                    Pages.Product.update subMsg model.productPageModel token

                msg =
                    Cmd.map transformProductMsg newSubMsg

                oldGroup =
                    model.group
            in
            ( { model
                | productPageModel = newProductPageModel
                , group = { oldGroup | products = newProductPageModel.products }
              }
            , msg
            )


transformProductMsg : Pages.Product.Msg -> Msg
transformProductMsg subMsg =
    ProductMsg subMsg
