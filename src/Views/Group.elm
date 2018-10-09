module Views.Group exposing (view)

import Html exposing (..)
import Html.Attributes exposing (attribute, class, href, name, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Models.Group exposing (Group)
import Msg exposing (..)
import Pages.Group exposing (Model)
import Views.Product


view : Model -> Html Msg
view model =
    div [ class "uk-margin" ]
        [ h1 [] [ text "Edit Group" ]
        , h4 [] [ text (toString model.id) ]
        , fieldset [ class "uk-fieldset" ]
            [ div [ class "uk-child-width-1-1@s uk-child-width-1-2@m" ]
                [ p [] [ text model.errorMsg ]
                , groupInputs model.group
                , Views.Product.view model.productPageModel
                , button
                    [ class "uk-button uk-button-primary uk-margin-small"
                    , type_ "button"
                    , onClick (GroupMsg Pages.Group.UpdateGroupRequest)
                    ]
                    [ text "Save" ]
                ]
            ]
        ]


groupInputs : Group -> Html Msg
groupInputs group =
    div []
        [ div [ class "uk-margin" ]
            [ input
                [ class "uk-input"
                , name "name"
                , type_ "input"
                , value group.name
                , placeholder "Name"
                , onInput (GroupMsg << Pages.Group.SetName)
                ]
                []
            ]
        , div [ class "uk-margin" ]
            [ select
                [ class "uk-select"
                , name "form_type"
                , onInput (GroupMsg << Pages.Group.SetFormType)
                ]
                [ option [ value "chubb" ] [ text "Chubb" ]
                , option [ value "ibew" ] [ text "IBEW" ]
                , option [ value "health_supp_only_product" ]
                    [ text "Health Supply Only Product" ]
                ]
            ]
        , div [ class "uk-margin" ]
            [ span [ class "uk-label" ]
                [ text "Payment Modes" ]
            , input
                [ class "uk-select"
                , name "payment_mode"
                , type_ "number"
                , value (toString group.payment_mode)
                , onInput (GroupMsg << Pages.Group.SetPaymentMode)
                ]
                []
            ]
        , div [ class "uk-margin" ]
            [ span [ class "uk-label" ] [ text "Disclosure" ]
            , textarea
                [ class "uk-textarea"
                , name "disclosure"
                , value group.disclosure
                , onInput (GroupMsg << Pages.Group.SetDisclosure)
                ]
                []
            ]
        ]
