module Pages.EditProduct exposing (Model, Msg(..), addComponentToModel, init, initialModel, update)

import Components.Product
import Http
import Task exposing (Task)


type Msg
    = ProductMsg Components.Product.Msg


type alias Model =
    { productComponent : Components.Product.Model
    }


initialModel : Model
initialModel =
    { productComponent = Components.Product.initialModel
    }


init : Int -> String -> Task Http.Error Model
init productId token =
    Task.map addComponentToModel (Components.Product.init productId token)


addComponentToModel : Components.Product.Model -> Model
addComponentToModel componentModel =
    { initialModel | productComponent = componentModel }


update : Msg -> Model -> String -> ( Model, Cmd Msg )
update msg model token =
    case msg of
        ProductMsg subMsg ->
            let
                ( newProductComponentModel, newSubMsg ) =
                    Components.Product.update subMsg model.productComponent token

                msg =
                    Cmd.map ProductMsg newSubMsg
            in
            ( { model | productComponent = newProductComponentModel }, msg )
