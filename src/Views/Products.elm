module Views.Products exposing (view)

import Html exposing (..)
import Html.Attributes exposing (attribute, class, href, name, placeholder, type_, value)
import Html.Events exposing (onClick)
import Models.Product exposing (Product)
import Msg exposing (..)
import Pages.Products exposing (Model)
import Route exposing (onClickRoute)
import Routes exposing (Route)


view : Model -> Html Msg
view model =
    div [ class "uk-margin uk-margin-top" ]
        [ div [ class "uk-flex uk-flex-wrap uk-flex-wrap around" ]
            [ h1 [ class "uk-width-1-2" ] [ text "Products" ]
            , div [ class "uk-width-1-2" ]
                [ a [ class "uk-button-primary uk-button uk-align-right" ]
                    [ text "Create Product" ]
                ]
            ]
        , div []
            [ table [ class "uk-table uk-table-striped" ]
                [ thead []
                    [ tr []
                        [ th [] [ text "Name" ]
                        , th [] []
                        ]
                    ]
                , tbody []
                    (viewProductList model.products)
                ]
            ]
        ]


viewProductList : List Product -> List (Html Msg)
viewProductList products =
    List.map viewProduct products


viewProduct : Product -> Html Msg
viewProduct product =
    tr []
        [ td []
            [ a ([ class "uk-link-text" ] ++ onClickRoute (Routes.EditProduct product.id))
                [ text product.name ]
            ]
        , td []
            [ button
                [ class "uk-button uk-button-danger uk-button-small"
                , type_ "button"
                ]
                [ text "Delete" ]
            ]
        ]
