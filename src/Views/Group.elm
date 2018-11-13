module Views.Group exposing (view)

import Components.Group exposing (Model)
import Html exposing (..)
import Html.Attributes exposing (attribute, checked, class, href, name, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Views.Helper exposing (convertMsgHtml)
import Views.Product


view : Components.Group.Model -> Html Components.Group.Msg
view model =
    div []
        [ fieldset [ class "uk-fieldset" ]
            [ div [ class "uk-child-width-1-1@s uk-child-width-1-2@m" ]
                [ p [] [ text model.errorMsg ]
                , groupInputs model
                ]
            , div [ class "uk-child-width-1-1@s" ]
                [ convertMsgHtml Components.Group.ProductMsg (Views.Product.view model.productPageModel)
                , button
                    [ class "uk-button uk-button-primary uk-margin-small"
                    , type_ "button"
                    , onClick Components.Group.UpdateGroupRequest
                    ]
                    [ text "Save" ]
                ]
            ]
        ]


groupInputs : Components.Group.Model -> Html Components.Group.Msg
groupInputs model =
    let
        group =
            model.group
    in
    div []
        [ div [ class "uk-margin" ]
            [ span [ class "uk-label" ]
                [ text "Name" ]
            , input
                [ class "uk-input"
                , name "name"
                , type_ "input"
                , value group.name
                , placeholder "Name"
                , onInput Components.Group.SetName
                ]
                []
            ]
        , div [ class "uk-margin" ]
            [ select
                [ class "uk-select"
                , name "form_type"
                , onInput Components.Group.SetFormType
                ]
                [ option [ value "life" ] [ text "Life" ]
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
                , onInput Components.Group.SetPaymentMode
                ]
                []
            ]
        , div [ class "uk-margin" ]
            [ toggleEmployeeContribution model ]
        , div [ class "uk-margin" ]
            [ span [ class "uk-label" ] [ text "Disclosure" ]
            , textarea
                [ class "uk-textarea"
                , name "disclosure"
                , value group.disclosure
                , onInput Components.Group.SetDisclosure
                ]
                []
            ]
        ]


toggleEmployeeContribution : Components.Group.Model -> Html Components.Group.Msg
toggleEmployeeContribution model =
    let
        group =
            model.group

        textBox =
            if model.showEmployeeContribution then
                div []
                    [ textarea
                        [ class "uk-textarea"
                        , name "employee_contribution"
                        , value group.employee_contribution
                        , onInput Components.Group.SetEmployeeContribution
                        ]
                        []
                    ]

            else
                div [] []
    in
    div []
        [ span [ class "uk-label" ]
            [ text "Contributions" ]
        , div [ class "uk-grid-small uk-child-width-auto uk-grid" ]
            [ label []
                [ input
                    [ class "uk-radio"
                    , type_ "radio"
                    , name "employee-contribution"
                    , checked (not model.showEmployeeContribution)
                    , onClick Components.Group.ToggleEmployeeContribution
                    ]
                    []
                , text "Employee Contribution"
                ]
            , label []
                [ input
                    [ class "uk-radio"
                    , type_ "radio"
                    , name "employee-contribution"
                    , checked model.showEmployeeContribution
                    , onClick Components.Group.ToggleEmployeeContribution
                    ]
                    []
                , text "100% Employer Paid"
                ]
            ]
        , textBox
        ]
