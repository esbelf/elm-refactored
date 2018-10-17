module Components.Group exposing (Model, Msg(..), addGroupToModel, init, initialModel, update)

import Http
import Models.Group exposing (Group)
import Requests.Group
import Task exposing (Task)


type Msg
    = SetName String
    | SetPaymentMode String
    | SetFormType String
    | SetDisclosure String
    | SetEmployeeContribution String
    | ToggleEmployeeContribution
    | GroupRequest
    | GroupLoaded (Result Http.Error Group)


type alias Model =
    { group : Group
    , errorMsg : String
    , id : Int
    , showEmployeeContribution : Bool
    }


initialModel : Model
initialModel =
    { group = Models.Group.init
    , errorMsg = ""
    , id = 0
    , showEmployeeContribution = False
    }


init : Int -> String -> Task Http.Error Model
init groupId token =
    Task.map addGroupToModel (Requests.Group.get groupId token)


addGroupToModel : Group -> Model
addGroupToModel group =
    let
        showEmployeeContribution =
            not (String.isEmpty group.employee_contribution)
    in
    { initialModel
        | id = group.id
        , group = group
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

        GroupRequest ->
            let
                request =
                    if model.group.id == 0 then
                        Requests.Group.create model.group token

                    else
                        Requests.Group.update model.group token

                newMsg =
                    request |> Task.attempt GroupLoaded
            in
            ( model, newMsg )

        GroupLoaded (Ok updatedGroup) ->
            ( { model | group = updatedGroup }, Cmd.none )

        GroupLoaded (Err error) ->
            ( { model | errorMsg = toString error }, Cmd.none )



--ProductMsg subMsg ->
--    let
--        ( newProductPageModel, newSubMsg ) =
--            Components.Product.update subMsg model.productPageModel token
--        msg =
--            Cmd.map ProductMsg newSubMsg
--        oldGroup =
--            model.group
--    in
--    ( { model
--        | productPageModel = newProductPageModel
--        , group = { oldGroup | products = newProductPageModel.products }
--      }
--    , msg
--    )
