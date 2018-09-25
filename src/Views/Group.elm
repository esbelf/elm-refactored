module Views.Group exposing (view)

import Msg exposing (..)
import Pages.Group exposing (Model)
-- import Models.Group exposing (Group)

import Html exposing (..)
import Html.Attributes exposing (attribute, class, href, name, type_, value, placeholder)

view : Model -> Html Msg
view model =
  div [ class "uk-margin" ]
    [ h1 [] [ text "Group"]
    , h4 [] [ text (toString model.id) ]
    ]

