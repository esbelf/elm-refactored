module Views.EditProduct exposing (view)

import Html exposing (..)
import Html.Attributes exposing (attribute, checked, class, href, name, placeholder, type_, value)
import Msg exposing (..)
import Pages.EditProduct
import Views.Components.Product
import Views.Helper exposing (convertMsgHtml)


view : Pages.EditProduct.Model -> Html Msg
view model =
    div [ class "uk-margin" ]
        [ h1 [] [ text "Edit Product" ]
        , convertMsgHtml EditProductMsg (convertMsgHtml Pages.EditProduct.ProductMsg (Views.Components.Product.view model.productComponent))
        ]
