module Views.Components.Product exposing (view)

--import Dict exposing (Dict)
--import EveryDict exposing (EveryDict)
--import Helpers.DecimalField as DecimalField exposing (DecimalField)
--import Json.Encode
--import List.Extra

import Components.Product
import Html exposing (..)
import Html.Attributes exposing (attribute, checked, class, href, name, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Models.Product


view : Components.Product.Model -> Html Components.Product.Msg
view model =
    div []
        [ fieldset [ class "uk-fieldset" ]
            [ div [ class "uk-child-width-1-1@s uk-child-width-1-2@m" ]
                [ p [] [ text model.errorMsg ]
                , productInputs model
                ]
            , div [ class "uk-child-width-1-1@s" ]
                [ button
                    [ class "uk-button uk-button-primary uk-margin-small"
                    , type_ "button"
                    , onClick Components.Product.ProductRequest
                    ]
                    [ text "Save" ]
                ]
            ]
        ]


productInputs : Components.Product.Model -> Html Components.Product.Msg
productInputs model =
    let
        product =
            model.product

        rates =
            product.rates
    in
    div []
        [ div [ class "uk-margin" ]
            [ input
                [ class "uk-input"
                , name "name"
                , type_ "input"
                , value model.product.name
                , placeholder "Name"
                , onInput Components.Product.SetName
                ]
                []
            ]
        , div [ class "uk-margin" ]
            [ select
                [ class "uk-select"
                , name "riskLevel"
                , onInput Components.Product.SetRiskLevel
                ]
                [ option [ value "normal" ] [ text "Normal" ]
                , option [ value "high" ] [ text "High" ]
                ]
            ]
        , dataTabs rates
        ]


dataTabs : List Models.Product.Column -> Html Components.Product.Msg
dataTabs columns =
    div []
        [ ul [ attribute "uk-tab" "1" ]
            [ li [ class "uk-active" ]
                [ text "something" ]
            , li []
                [ text "something 2" ]
            ]
        ]



--dataTab : Models.Product.Column -> Html Components.Product.Msg
--dataTab column =
