module Views.CreateProduct exposing (view)

import Html exposing (..)
import Html.Attributes exposing (attribute, checked, class, href, name, placeholder, type_, value)
import Msg exposing (..)
import Pages.CreateProduct
import Views.Components.Product
import Views.Helper exposing (convertMsgHtml)


view : Pages.CreateProduct.Model -> Html Msg
view model =
    div [ class "uk-margin" ]
        [ h1 [] [ text "Create Product" ]
        , convertMsgHtml CreateProductMsg (convertMsgHtml Pages.CreateProduct.ProductMsg (Views.Components.Product.view model.productComponent))
        ]
