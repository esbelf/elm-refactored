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


view : Components.Product.Model -> Html Components.Product.Msg
view model =
    div []
        [ div []
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
        , div []
            [ select
                [ class "uk-select"
                , name "riskLevel"
                , onInput Components.Product.SetRiskLevel
                ]
                [ option [ value "normal" ] [ text "Normal" ]
                , option [ value "high" ] [ text "High" ]
                ]
            ]
        ]
