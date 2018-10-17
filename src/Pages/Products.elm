module Pages.Products exposing (Model, Msg(..), addProductsToModel, init, initialModel, update)

import Http
import Models.Product exposing (Product)
import Pages.Helper exposing (..)
import Requests.Product
import Task exposing (Task)


type Msg
    = DeleteProductRequest Int
    | DeleteProduct Int (Result Http.Error String)


type alias Model =
    { products : List Product
    , errorMsg : String
    }


initialModel : Model
initialModel =
    { products = []
    , errorMsg = ""
    }


init : String -> Task Http.Error Model
init token =
    Task.map addProductsToModel (Requests.Product.getAll token)


addProductsToModel : List Product -> Model
addProductsToModel products =
    { initialModel | products = products }


update : Msg -> Model -> String -> ( Model, Cmd Msg )
update msg model token =
    case msg of
        DeleteProductRequest productId ->
            let
                newMsg =
                    Requests.Product.delete productId token
                        |> Task.attempt (DeleteProduct productId)
            in
            ( model, newMsg )

        DeleteProduct id (Ok message) ->
            ( { model | products = removeModelFromList id model.products }, Cmd.none )

        DeleteProduct id (Err error) ->
            ( { model | errorMsg = toString error }, Cmd.none )
