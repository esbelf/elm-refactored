module Views.Product exposing (view)

import Components.Product
import Dict exposing (Dict)
import EveryDict exposing (EveryDict)
import Helpers.DecimalField as DecimalField exposing (DecimalField)
import Html exposing (Html, a, b, button, div, h2, hr, input, label, li, option, p, pre, select, span, table, tbody, td, text, textarea, th, thead, tr, ul)
import Html.Attributes exposing (attribute, checked, class, disabled, name, placeholder, rows, rowspan, selected, style, title, type_, value)
import Html.Events exposing (onClick, onFocus, onInput)
import Json.Encode
import List.Extra
import Models.Product exposing (..)
import Requests.Product exposing (encode)
import Views.Modal as Modal exposing (ModalButtonStyle(..), modalButton)


view : Components.Product.Model -> Html Components.Product.Msg
view model =
    div []
        (List.indexedMap renderProduct model.products
            ++ [ a [ onClick Components.Product.AddProduct ]
                    [ text "Add Product" ]
               , textarea
                    [ name "group[product_pricing]"
                    , style "display" "none"
                    ]
                    [ text (Json.Encode.encode 0 <| encode model.products) ]
               , renderModal model
               ]
        )


renderProduct : Int -> Product -> Html Components.Product.Msg
renderProduct index product =
    let
        benefitTier =
            product.benefits
                |> List.Extra.getAt product.focusedBenefit
                |> Maybe.withDefault (Tier "ERROR" -1)
    in
    div [ class "product-border" ]
        [ input
            [ class "uk-input"
            , onInput (Components.Product.SetProductName index)
            , placeholder "Product Name"
            , value product.name
            ]
            []
        , riskLevelToggle index product
        , benefitTabs index product
        , div [ class "uk-margin" ]
            [ div [ class "uk-flex uk-flex-wrap around" ]
                [ textarea
                    [ class "uk-input uk-width-3-5"
                    , style "line-height" "1.5rem"
                    , onInput (Components.Product.SetBenefitDisplay index benefitTier.key)
                    , rows 3
                    , value benefitTier.display
                    ]
                    []
                , div [ class "uk-width-2-5" ]
                    [ button
                        [ class "uk-button uk-button-secondary uk-button-small"
                        , type_ "button"
                        , onClick (Components.Product.ConfirmRemoveTier index BenefitTier benefitTier.key)
                        ]
                        [ text "Remove" ]
                    , button
                        [ class "uk-button uk-button-secondary uk-button-small"
                        , type_ "button"
                        , onClick (Components.Product.AddBenefitTier index)
                        ]
                        [ text "Add" ]
                    ]
                ]
            ]
        , table [ class "uk-table uk-table-divider uk-table-hover" ]
            [ tbody []
                ([ headerRow index product ]
                    ++ tableBody index product
                )
            ]
        , div [ class "uk-margin" ]
            [ div [ class "uk-width-1-2" ]
                [ button
                    [ class "uk-button uk-button-secondary uk-button-small"
                    , type_ "button"
                    , onClick (Components.Product.AddAgeTier index)
                    ]
                    [ text "Add Age Tier" ]
                ]
            ]
        ]


riskLevelToggle : Int -> Product -> Html Components.Product.Msg
riskLevelToggle index product =
    let
        hasRiskLevels =
            List.length product.riskLevels > 1
    in
    div [ class "uk-margin" ]
        [ div [ class "uk-flex uk-flex-wrap around" ]
            [ div [ class "uk-child-width-1-1@s" ]
                [ select
                    [ class "uk-select"
                    , name "risk-levels-toggle"
                    , onInput (Components.Product.SetRiskLevel index)
                    ]
                    [ option
                        [ value (riskLevelToValue NormalRisk)
                        , selected (not hasRiskLevels)
                        ]
                        [ text (riskLevelToLabel NormalRisk) ]
                    , option
                        [ value (riskLevelToValue HighRisk)
                        , selected hasRiskLevels
                        ]
                        [ text (riskLevelToLabel HighRisk) ]
                    ]
                ]
            , div [ class "uk-child-width-1-1@s" ]
                [ input
                    [ class "uk-input"
                    , value product.riskLabel
                    , placeholder "Label"
                    , disabled (not hasRiskLevels)
                    , onInput (Components.Product.SetRiskLabel index)
                    ]
                    []
                ]
            ]
        ]


benefitTabs : Int -> Product -> Html Components.Product.Msg
benefitTabs index product =
    ul [ class "uk-child-width-expand", attribute "uk-tab" "1" ]
        (List.map (benefitTab index product.focusedBenefit) product.benefits)


benefitTab : Int -> Int -> Tier -> Html Components.Product.Msg
benefitTab productIndex benefitIndex benefit =
    let
        tabClass key =
            if benefitIndex == key then
                "uk-active"

            else
                ""
    in
    li
        [ class (tabClass benefit.key)
        , onClick (Components.Product.FocusBenefit productIndex benefit.key)
        ]
        [ a [] [ text benefit.display ] ]


headerRow : Int -> Product -> Html Components.Product.Msg
headerRow index product =
    tr []
        [ th []
            []
        , th []
            [ text "Employee" ]
        , th []
            [ text "+ Children" ]
        , th []
            [ text "+ Spouse" ]
        , th []
            [ text "+ Family" ]
        , th []
            []
        , th
            [ rowspan (List.length product.ages + 2)
            , style "vertical-align" "top"
            , style "width" "180px"
            ]
            [ deductionPriceTable index product
            ]
        ]


deductionPriceTable : Int -> Product -> Html Components.Product.Msg
deductionPriceTable index product =
    case product.focus of
        Nothing ->
            text ""

        Just ( ageIndex, coverage, risk ) ->
            let
                ageTier =
                    product.ages
                        |> List.drop ageIndex
                        |> List.head
                        |> Maybe.withDefault (Tier "ERROR" -1)

                coverageDisplay =
                    case coverage of
                        Employee ->
                            "EE"

                        PlusKids ->
                            "+CH"

                        PlusSpouse ->
                            "+SP"

                        PlusFamily ->
                            "+FAM"

                riskDisplay =
                    case risk of
                        NormalRisk ->
                            "Normal Risk"

                        HighRisk ->
                            "High Risk"
            in
            div []
                [ div []
                    [ h2 [] [ text "Deductions" ]
                    , div []
                        [ text "Coverage Tier: "
                        , b [] [ text coverageDisplay ]
                        ]
                    , div []
                        [ text "Age Tier: "
                        , b [] [ text ageTier.display ]
                        ]
                    , div []
                        [ text "Risk Tier: "
                        , b [] [ text riskDisplay ]
                        ]
                    ]
                , hr [] []
                , deductionPriceRow ( index, ageIndex, coverage, risk ) product Weekly
                , deductionPriceRow ( index, ageIndex, coverage, risk ) product BiWeekly
                , deductionPriceRow ( index, ageIndex, coverage, risk ) product SemiMonthly
                , deductionPriceRow ( index, ageIndex, coverage, risk ) product Monthly
                ]


deductionModeLabel : DeductionMode -> String
deductionModeLabel deductMode =
    case deductMode of
        Weekly ->
            "Weekly"

        BiWeekly ->
            "Bi-weekly"

        SemiMonthly ->
            "Semi-monthly"

        Monthly ->
            "Monthly"


getDeduction : ( Int, Coverage, RiskLevel ) -> Product -> DeductionMode -> DecimalField
getDeduction ( ageIndex, coverage, riskLevel ) product deductMode =
    let
        agePricing =
            EveryDict.get coverage product.pricing
                |> Maybe.withDefault Dict.empty

        benefitPricing =
            Dict.get ageIndex agePricing
                |> Maybe.withDefault Dict.empty

        coveragePricing =
            Dict.get product.focusedBenefit benefitPricing
                |> Maybe.withDefault EveryDict.empty

        deductPricing =
            EveryDict.get deductMode coveragePricing
                |> Maybe.withDefault EveryDict.empty
    in
    EveryDict.get riskLevel deductPricing
        |> Maybe.withDefault (DecimalField.fromFloat 0.0)


calculateDeduction : DecimalField -> DeductionMode -> DecimalField
calculateDeduction monthly deductMode =
    let
        perYear =
            case deductMode of
                Weekly ->
                    52

                BiWeekly ->
                    26

                SemiMonthly ->
                    24

                Monthly ->
                    12
    in
    monthly.value
        * 12
        / perYear
        |> DecimalField.fromFloat


deductionPriceRow : ( Int, Int, Coverage, RiskLevel ) -> Product -> DeductionMode -> Html Components.Product.Msg
deductionPriceRow ( productIndex, ageIndex, coverage, risk ) product deductMode =
    if deductMode == Monthly || product.explicitDeductions then
        explicitDeductionPriceRow ( productIndex, ageIndex, coverage, risk ) product deductMode

    else
        let
            monthly =
                getDeduction ( ageIndex, coverage, risk ) product Monthly

            calculated =
                calculateDeduction monthly deductMode
        in
        div []
            [ label []
                [ text (deductionModeLabel deductMode) ]
            , input
                [ value (DecimalField.toFixed calculated.value 2)
                , disabled True
                ]
                []
            ]


explicitDeductionPriceRow : ( Int, Int, Coverage, RiskLevel ) -> Product -> DeductionMode -> Html Components.Product.Msg
explicitDeductionPriceRow ( productIndex, ageIndex, coverage, risk ) product deductMode =
    let
        price =
            getDeduction ( ageIndex, coverage, risk ) product deductMode
    in
    div []
        [ label []
            [ text (deductionModeLabel deductMode) ]
        , input
            [ value (DecimalField.inputValue price)
            , onInput (Components.Product.SetPrice productIndex ageIndex coverage deductMode risk)
            ]
            []
        ]


tableBody : Int -> Product -> List (Html Components.Product.Msg)
tableBody index product =
    List.map (renderBenefitRow index product) product.ages


renderBenefitRow : Int -> Product -> Tier -> Html Components.Product.Msg
renderBenefitRow index product ageTier =
    tr []
        ([ td []
            [ input
                [ class "uk-input"
                , value ageTier.display
                , onInput (Components.Product.SetTierDisplay index ageTier.key)
                ]
                []
            ]
         ]
            ++ List.map (renderCell index ageTier product.focusedBenefit product.pricing product.riskLevels)
                [ Employee, PlusKids, PlusSpouse, PlusFamily ]
            ++ [ td []
                    [ button
                        [ class "uk-button uk-button-secondary uk-button-small"
                        , type_ "button"
                        , onClick (Components.Product.ConfirmRemoveTier index AgeTier ageTier.key)
                        ]
                        [ text "Remove" ]
                    ]
               ]
        )


renderCell : Int -> Tier -> Int -> EveryDict Coverage PriceGrid -> List RiskLevel -> Coverage -> Html Components.Product.Msg
renderCell productIndex ageTier benefitIndex pricing riskLevels coverage =
    let
        multiRisk =
            List.length riskLevels > 1

        prices =
            EveryDict.get coverage pricing
                |> Maybe.withDefault Dict.empty

        agePrices =
            Dict.get ageTier.key prices
                |> Maybe.withDefault Dict.empty

        benefitPrices =
            Dict.get benefitIndex agePrices
                |> Maybe.withDefault EveryDict.empty

        deductMode =
            Monthly

        price risk =
            let
                prices =
                    EveryDict.get deductMode benefitPrices
                        |> Maybe.withDefault EveryDict.empty
            in
            EveryDict.get risk prices
                |> Maybe.withDefault (DecimalField.fromFloat 0.0)
    in
    td []
        [ div [ class "uk-grid-small" ]
            (List.map (renderInput productIndex ageTier.key coverage deductMode price multiRisk) riskLevels)
        ]


renderInput : Int -> Int -> Coverage -> DeductionMode -> (RiskLevel -> DecimalField) -> Bool -> RiskLevel -> Html Components.Product.Msg
renderInput productIndex ageIndex coverage deductMode getPrice multiRisk risk =
    let
        className =
            if multiRisk then
                "uk-width-1-2"

            else
                ""
    in
    div
        [ class className
        , style "float" "left"
        ]
        [ input
            [ class "uk-input"
            , value (DecimalField.inputValue (getPrice risk))
            , onInput (Components.Product.SetPrice productIndex ageIndex coverage deductMode risk)
            , onFocus (Components.Product.SetFocus productIndex ageIndex coverage risk)
            ]
            []
        ]


renderModal : Components.Product.Model -> Html Components.Product.Msg
renderModal model =
    case model.removeTier of
        Nothing ->
            text ""

        Just ( productIndex, tierType, tierIndex ) ->
            let
                product =
                    model.products
                        |> List.Extra.getAt productIndex
                        |> Maybe.withDefault Models.Product.init

                tierTypeDisplay =
                    case tierType of
                        AgeTier ->
                            "Age Tier"

                        BenefitTier ->
                            "Benefit Tier"

                tierList =
                    case tierType of
                        AgeTier ->
                            product.ages

                        BenefitTier ->
                            product.benefits

                tierDisplay =
                    tierList
                        |> List.Extra.getAt tierIndex
                        |> Maybe.withDefault (Tier "ERROR" -1)
                        |> .display

                tierExtraDisplay =
                    case tierType of
                        AgeTier ->
                            " (across all benefit tiers)"

                        BenefitTier ->
                            ""

                content =
                    p []
                        [ text
                            ("You are removing the "
                                ++ tierTypeDisplay
                                ++ " named \""
                                ++ tierDisplay
                                ++ "\""
                                ++ tierExtraDisplay
                                ++ " and deleting all associated pricing.  This cannot be undone.  Are you sure you want to continue?"
                            )
                        ]

                buttons =
                    [ modalButton "Cancel" Components.Product.CancelRemoveTier ModalDefault
                    , modalButton "Delete" Components.Product.RemoveTier ModalPrimary
                    ]
            in
            Modal.displayModal "Remove Tier" content buttons
