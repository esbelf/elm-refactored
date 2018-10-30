module Views.Components.Product exposing (view)

--import Dict exposing (Dict)
--import EveryDict exposing (EveryDict)
--import Helpers.DecimalField as DecimalField exposing (DecimalField)
--import Json.Encode
--import List.Extra

import Components.Product
import Html exposing (..)
import Html.Attributes exposing (attribute, checked, class, href, name, placeholder, title, type_, value)
import Html.Events exposing (onClick, onInput)
import Models.Product


view : Components.Product.Model -> Html Components.Product.Msg
view model =
    div []
        [ fieldset [ class "uk-fieldset" ]
            [ div [ class "uk-child-width-1-1@s uk-child-width-1-1@m" ]
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
        , div [ class "uk-margin" ]
            [ input
                [ class "uk-input"
                , name "columnName"
                , type_ "input"
                , placeholder "New Column Header"
                ]
                []
            , span
                [ attribute "uk-icon" "plus"
                , title "Add Column Header"
                ]
                []
            ]
        , dataTabs rates
        ]


dataTabs : List Models.Product.Column -> Html Components.Product.Msg
dataTabs columns =
    div []
        [ ul [ attribute "uk-tab" "" ]
            (dataTabsHeader columns)
        , ul [ class "uk-switcher uk-margin" ]
            (dataTabsBody columns)
        ]


dataTabsHeader : List Models.Product.Column -> List (Html Components.Product.Msg)
dataTabsHeader columns =
    List.map viewDataTabHeader columns


viewDataTabHeader : Models.Product.Column -> Html Components.Product.Msg
viewDataTabHeader column =
    li []
        [ a [ href "#" ] [ text column.name ] ]


dataTabsBody : List Models.Product.Column -> List (Html Components.Product.Msg)
dataTabsBody columns =
    List.map viewDataTabBody columns


viewDataTabBody : Models.Product.Column -> Html Components.Product.Msg
viewDataTabBody column =
    li []
        [ p [] [ text column.name ]
        ]
