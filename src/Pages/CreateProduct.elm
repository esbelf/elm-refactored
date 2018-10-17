module Pages.CreateProduct exposing (Model, Msg(..), initialModel, update)

import Components.Product


type Msg
    = ProductMsg Components.Product.Msg


type alias Model =
    { productComponent : Components.Product.Model
    }


initialModel : Model
initialModel =
    { productComponent = Components.Product.initialModel
    }


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
