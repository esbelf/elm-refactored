module Views.GroupForm exposing (view)

import Html exposing (..)
import Html.Attributes exposing (attribute, checked, class, height, href, name, placeholder, src, tabindex, type_, value, width)
import Html.Events exposing (onClick, onInput)
import Json.Decode as JD
import Models.Group as Group exposing (Group, Logo(..))
import Pages.GroupForm as GroupForm exposing (Model, Msg(..))
import Views.Helper exposing (convertMsgHtml, unionSelectOptions)



-- import Views.Product


view : GroupForm.Model -> Html GroupForm.Msg
view model =
    div []
        [ fieldset [ class "uk-fieldset" ]
            [ div [ class "uk-child-width-1-1@s uk-child-width-1-2@m" ]
                [ p [] [ text model.errorMsg ]
                , groupInputs model
                ]
            , div [ class "uk-child-width-1-1@s" ]
                -- [ convertMsgHtml GroupForm.ProductMsg (Views.Product.view model.productPageModel)
                [ text "--Product display would go here--"
                , button
                    [ class "uk-button uk-button-primary uk-margin-small"
                    , type_ "button"
                    , onClick GroupForm.SaveGroupRequest
                    ]
                    [ text "Save" ]
                ]
            ]
        ]


groupInputs : GroupForm.Model -> Html GroupForm.Msg
groupInputs model =
    let
        group =
            model.group
    in
    div []
        [ div [ class "uk-margin" ]
            [ span [ class "uk-label" ]
                [ text "Group Name" ]
            , input
                [ class "uk-input"
                , name "name"
                , type_ "input"
                , value group.name
                , placeholder "Name"
                , onInput SetName
                ]
                []
            ]
        , div [ class "uk-margin" ]
            (viewLogoUploadControl model.group.logo)
        , div [ class "uk-margin" ]
            [ select
                [ class "uk-select"
                , name "form_type"
                , onInput SetFormType
                ]
                (unionSelectOptions Group.allFormTypes Group.formTypeToString Group.formTypeToLabel group.form_type)
            ]
        , div [ class "uk-margin" ]
            [ span [ class "uk-label" ]
                [ text "Payroll Deduction Mode" ]
            , input
                [ class "uk-select"
                , name "payment_mode"
                , type_ "number"
                , value (String.fromInt group.payment_mode)
                , onInput SetPaymentMode
                ]
                []
            ]
        , div [ class "uk-margin" ]
            [ toggleEmployeeContribution model ]
        , div [ class "uk-margin" ]
            [ span [ class "uk-label" ] [ text "Disclosure" ]
            , textarea
                [ class "uk-textarea"
                , name "Signiture Disclosure"
                , value group.disclosure
                , onInput SetDisclosure
                ]
                []
            ]
        ]


viewLogoUploadControl : Logo -> List (Html GroupForm.Msg)
viewLogoUploadControl logo =
    [ span [ class "uk-label" ]
        [ text "Logo Image" ]
    , div [ class " uk-grid-small uk-child-width-auto uk-grid" ]
        [ div [ class "uk-form-custom" ]
            [ input
                [ type_ "file"
                , Html.Attributes.id GroupForm.formUploadId
                , Html.Events.on "change"
                    (JD.succeed FileSelected)
                ]
                []
            , button
                [ class "uk-button uk-button-default"
                , type_ "button"
                , tabindex -1
                ]
                [ fileButtonText logo ]
            , logoDisplay logo
            ]
        ]
    ]


logoDisplay : Logo -> Html msg
logoDisplay logo =
    case logo of
        EmptyLogo ->
            text ""

        AttachedLogo url ->
            Html.img [ src url, height 100, width 100 ] []

        UploadingLogo data fileName maybeOldUrl ->
            Html.img [ src data, height 100, width 100 ] []


fileButtonText : Logo -> Html msg
fileButtonText logo =
    case logo of
        EmptyLogo ->
            text "Select Logo"

        AttachedLogo _ ->
            text "Upload New Logo"

        UploadingLogo _ _ _ ->
            text "Change Selected Logo"


toggleEmployeeContribution : GroupForm.Model -> Html GroupForm.Msg
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
                        , onInput SetEmployeeContribution
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
                    , onClick ToggleEmployeeContribution
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
                    , onClick ToggleEmployeeContribution
                    ]
                    []
                , text "100% Employer Paid"
                ]
            ]
        , textBox
        ]
