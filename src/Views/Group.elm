module Views.Group exposing (view)

-- import Models.Group exposing (Group)

import Html exposing (..)
import Html.Attributes exposing (attribute, checked, class, href, name, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Msg exposing (..)
import Pages.Group exposing (Model)
import Pages.Product
import Views.Product



-- Html Pages.Product.Msg -> Html Pages.Group.Msg


convertToGroupMsgHtml : (subMsg -> mainMsg) -> Html subMsg -> Html mainMsg
convertToGroupMsgHtml toGroupMsg subMsgHtml =
    Html.map toGroupMsg subMsgHtml


view : Pages.Group.Model -> Html Msg
view model =
    div [ class "uk-margin" ]
        [ h1 [] [ text "Edit Group" ]
        , h4 [] [ text (toString model.id) ]
        , fieldset [ class "uk-fieldset" ]
            [ div [ class "uk-child-width-1-1@s uk-child-width-1-2@m" ]
                [ p [] [ text model.errorMsg ]
                , groupInputs model
                ]
            , div [ class "uk-child-width-1-1@s" ]
                [ convertToGroupMsgHtml GroupMsg (convertToGroupMsgHtml Pages.Group.ProductMsg (Views.Product.view model.productPageModel))
                , button
                    [ class "uk-button uk-button-primary uk-margin-small"
                    , type_ "button"
                    , onClick (GroupMsg Pages.Group.UpdateGroupRequest)
                    ]
                    [ text "Save" ]
                ]
            ]
        ]


groupInputs : Model -> Html Msg
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
                , onInput (GroupMsg << Pages.Group.SetPaymentMode)
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
                , onInput (GroupMsg << Pages.Group.SetDisclosure)
                ]
                []
            ]
        ]


toggleEmployeeContribution : Model -> Html Msg
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
                        , onInput (GroupMsg << Pages.Group.SetEmployeeContribution)
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
                    , onClick (GroupMsg Pages.Group.ToggleEmployeeContribution)
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
                    , onClick (GroupMsg Pages.Group.ToggleEmployeeContribution)
                    ]
                    []
                , text "100% Employer Paid"
                ]
            ]
        , textBox
        ]
