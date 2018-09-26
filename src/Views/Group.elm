module Views.Group exposing (view)

import Msg exposing (..)
import Pages.Group exposing (Model)
-- import Models.Group exposing (Group)

import Html exposing (..)
import Html.Events exposing (onInput)
import Html.Attributes exposing (attribute, class, href, name, type_, value, placeholder)

view : Model -> Html Msg
view model =
  div [ class "uk-margin" ]
    [ h1 [] [ text "Edit Group"]
    , h4 [] [ text (toString model.id) ]
    , fieldset [ class "uk-fieldset" ]
      [ div [ class "uk-child-width-1-1@s uk-child-width-1-2@m" ]
        [ p [] [ text model.errorMsg ]
        , (groupInputs model)
        ]
      ]
    ]


groupInputs : Model -> Html Msg
groupInputs model =
    div []
      [ div [ class "uk-margin" ]
        [ input
          [ class "uk-input"
          , name "name"
          , type_ "input"
          , value model.inputName
          , placeholder "Name"
          , onInput (GroupMsg << Pages.Group.SetName)
          ] []
        ]
      , div [ class "uk-margin" ]
        [ span [ class "uk-label" ]
          [ text "Payment Modes" ]
        , input
          [ class "uk-select"
          , name "payment_mode"
          , type_ "number"
          , value (toString model.inputPaymentMode)
          , onInput (GroupMsg << Pages.Group.SetPaymentMode)
          ] []
        ]
      ]


--restrictPaymentMode : Int -> Int
--restrictPaymentMode num =
--  if num < 1 then
--    1
--  else
--    num

