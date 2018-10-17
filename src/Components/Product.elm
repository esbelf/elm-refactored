module Components.Product exposing (Model, Msg(..), init, initialModel, update)

-- import Dict exposing (Dict)
-- import EveryDict exposing (EveryDict)
-- import Helpers.DecimalField
-- import List.Extra exposing (removeAt, updateAt)

import Http
import Models.Product exposing (Product)
import Requests.Product
import Task exposing (Task)


type Msg
    = SetName String
    | SetRiskLevel String
    | ProductRequest
    | ProductLoaded (Result Http.Error Product)


type alias Model =
    { product : Product
    , errorMsg : String
    , id : Int
    , riskLevel : String
    }


initialModel : Model
initialModel =
    { product = Models.Product.init
    , errorMsg = ""
    , id = 0
    , riskLevel = ""
    }


init : Int -> String -> Task Http.Error Model
init productId token =
    Task.map addProductToModel (Requests.Product.get productId token)


addProductToModel : Product -> Model
addProductToModel product =
    { initialModel
        | id = product.id
        , product = product
    }


update : Msg -> Model -> String -> ( Model, Cmd Msg )
update msg model token =
    case msg of
        SetName name ->
            let
                oldProduct =
                    model.product
            in
            ( { model | product = { oldProduct | name = name } }, Cmd.none )

        SetRiskLevel level ->
            ( { model | riskLevel = level }, Cmd.none )

        ProductRequest ->
            let
                request =
                    if model.product.id == 0 then
                        Requests.Product.create model.product token

                    else
                        Requests.Product.update model.product token

                newMsg =
                    request |> Task.attempt ProductLoaded
            in
            ( model, newMsg )

        ProductLoaded (Ok updatedProduct) ->
            ( { model | product = updatedProduct }, Cmd.none )

        ProductLoaded (Err error) ->
            ( { model | errorMsg = toString error }, Cmd.none )
