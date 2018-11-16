module Components.Group exposing (Model, Msg(..), addGroupToModel, init, initialModel, update)

import Components.Product
import Http
import Models.Group exposing (FormType, Group)
import Navigation
import Requests.Group
import Task exposing (Task)


type Msg
    = SetName String
    | SetPaymentMode String
    | SetFormType String
    | SetDisclosure String
    | SetEmployeeContribution String
    | ToggleEmployeeContribution
    | SaveGroupRequest
    | UpdateGroup (Result Http.Error Group)
    | ProductMsg Components.Product.Msg


type alias Model =
    { group : Group
    , errorMsg : String
    , id : Maybe Int
    , productPageModel : Components.Product.Model
    , showEmployeeContribution : Bool
    }


initialModel : Model
initialModel =
    { group = Models.Group.init
    , errorMsg = ""
    , id = Nothing
    , productPageModel = Components.Product.init
    , showEmployeeContribution = False
    }


init : Int -> String -> Task Http.Error Model
init groupId token =
    Task.map addGroupToModel (Requests.Group.get groupId token)


addGroupToModel : Group -> Model
addGroupToModel group =
    let
        pageProductModel =
            Components.Product.init

        productPageModel =
            { pageProductModel | products = group.products }

        showEmployeeContribution =
            not (String.isEmpty group.employee_contribution)
    in
    { initialModel
        | id = group.id
        , group = group
        , productPageModel = productPageModel
        , showEmployeeContribution = showEmployeeContribution
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
                    paymentMode
                        |> String.toInt
                        |> Result.withDefault oldGroup.payment_mode
            in
            ( { model | group = { oldGroup | payment_mode = newPaymentMode } }, Cmd.none )

        SetFormType formTypeStr ->
            let
                oldGroup =
                    model.group

                newFormType =
                    formTypeStr
                        |> Models.Group.stringToFormType
                        |> Result.withDefault oldGroup.form_type
            in
            ( { model | group = { oldGroup | form_type = newFormType } }, Cmd.none )

        SetDisclosure disclosure ->
            let
                oldGroup =
                    model.group
            in
            ( { model | group = { oldGroup | disclosure = disclosure } }, Cmd.none )

        SetEmployeeContribution contributionText ->
            let
                oldGroup =
                    model.group
            in
            ( { model | group = { oldGroup | employee_contribution = contributionText } }, Cmd.none )

        ToggleEmployeeContribution ->
            if model.showEmployeeContribution then
                ( { model | showEmployeeContribution = not model.showEmployeeContribution }, Cmd.none )

            else
                let
                    oldGroup =
                        model.group
                in
                ( { model
                    | showEmployeeContribution = not model.showEmployeeContribution
                    , group = { oldGroup | employee_contribution = "" }
                  }
                , Cmd.none
                )

        SaveGroupRequest ->
            let
                newMsg =
                    save model.group token
            in
            ( model, newMsg )

        UpdateGroup (Ok updatedGroup) ->
            let
                cmd =
                    Navigation.newUrl "/groups"
            in
            ( { model | group = updatedGroup }, cmd )

        UpdateGroup (Err error) ->
            ( { model | errorMsg = toString error }, Cmd.none )

        ProductMsg subMsg ->
            let
                ( newProductPageModel, newSubMsg ) =
                    Components.Product.update subMsg model.productPageModel token

                msg =
                    Cmd.map ProductMsg newSubMsg

                oldGroup =
                    model.group
            in
            ( { model
                | productPageModel = newProductPageModel
                , group = { oldGroup | products = newProductPageModel.products }
              }
            , msg
            )


save : Group -> String -> Cmd Msg
save group token =
    case group.id of
        Just groupId ->
            Requests.Group.update group token
                |> Task.attempt UpdateGroup

        Nothing ->
            Requests.Group.create group token
                |> Task.attempt UpdateGroup
