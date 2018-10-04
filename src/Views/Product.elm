module Views.Product exposing (view)

import Helpers.DecimalField as DecimalField exposing (DecimalField)
import Requests.Product exposing (encode)
import Models.Product exposing (..)
import Pages.Product
import Pages.Group
import Msg exposing (..)

import Html exposing (Html, a, b, button, div, h2, hr, input, label, li, p, pre, span, table, tbody, td, text, textarea, th, thead, tr, ul)
import Html.Attributes exposing (attribute, checked, class, disabled, name, placeholder, rows, rowspan, style, title, type_, value)
import Html.Events exposing (onClick, onFocus, onInput)
import EveryDict exposing (EveryDict)
import Dict exposing (Dict)
import Json.Encode
import List.Extra

view : Pages.Product.Model -> Html Msg
view model =
  div []
      ((List.indexedMap renderProduct model.products)
      ++
      [ a [ onClick (GroupMsg (Pages.Group.ProductMsg Pages.Product.AddProduct)) ]
          [ text "Add Product" ]
      , textarea [ name "group[product_pricing]"
                 , style [ ("display", "none") ]
                 ]
                 [ text (Json.Encode.encode 0 <| encode model.products) ]
      , renderModal model
      ])


renderProduct : Int -> Product -> Html Msg
renderProduct index product =
    let
        benefitTier =
            product.benefits
            |> List.Extra.getAt product.focusedBenefit
            |> Maybe.withDefault (Tier "ERROR" -1)
        log =
            Debug.log "benefitTier" benefitTier
    in
    div []
        [ input [ class "uk-input"
                , onInput (GroupMsg << Pages.Group.ProductMsg << Pages.Product.SetProductName index)
                , placeholder "Product Name"
                , value product.name
                ]
                []
        , explicitDeductionToggle index product
        , riskLevelToggle index product
        , benefitTabs index product
        , div []
              [ textarea [ class "uk-input uk-width-4-5"
                         , style [ ("line-height", "1.5rem") ]
                         , onInput (GroupMsg << Pages.Group.ProductMsg << Pages.Product.SetBenefitDisplay index benefitTier.key)
                         , rows 3
                         , value benefitTier.display
                         ]
                         []
              , div [ class "uk-align-right" ]
                    [ span [ attribute "uk-icon" "close"
                           , onClick (GroupMsg (Pages.Group.ProductMsg (Pages.Product.ConfirmRemoveTier index BenefitTier benefitTier.key)))
                           , title "Remove Benefit Tier"
                           ] []
                    , span [ attribute "uk-icon" "plus-circle"
                           , onClick (GroupMsg (Pages.Group.ProductMsg (Pages.Product.AddBenefitTier index)))
                           , title "Add Benefit Tier"
                           ] []
                    ]
              ]
        , table [ class "uk-table uk-table-divider uk-table-hover" ]
                [ tbody []
                        ([ headerRow index product ]
                        ++
                        (tableBody index product))
                ]
        ]

explicitDeductionToggle : Int -> Product -> Html Msg
explicitDeductionToggle index product =
    div [ class "uk-margin uk-grid-small uk-child-width-auto uk-grid" ]
        [ label []
                [ input [ class "uk-radio"
                        , type_ "radio"
                        , name "exp-deduction"
                        , checked (not product.explicitDeductions)
                        , onClick (GroupMsg (Pages.Group.ProductMsg (Pages.Product.ToggleExplicitDeductions index)))
                        ] []
                , text "Auto-calculate deductions from monthly"
                ]
        , label []
                [ input [ class "uk-radio"
                        , type_ "radio"
                        , name "exp-deduction"
                        , checked (product.explicitDeductions)
                        , onClick (GroupMsg (Pages.Group.ProductMsg (Pages.Product.ToggleExplicitDeductions index)))
                        ] []
                , text "Enter explicit deduction amounts"
                ]
        ]

riskLevelToggle : Int -> Product -> Html Msg
riskLevelToggle index product =
    let
        hasRiskLevels =
            List.length product.riskLevels > 1
    in
    div [ class "uk-margin uk-grid-small uk-child-width-auto uk-grid" ]
        [ label []
                [ input [ class "uk-radio"
                        , type_ "radio"
                        , name "risk-levels-toggle"
                        , checked (not hasRiskLevels)
                        , onClick (GroupMsg (Pages.Group.ProductMsg (Pages.Product.ToggleRiskLevel index)))
                        ] []
                , text "Normal risk level only"
                ]
        , label []
                [ input [ class "uk-radio"
                        , type_ "radio"
                        , name "risk-levels-toggle"
                        , checked hasRiskLevels
                        , onClick (GroupMsg (Pages.Group.ProductMsg (Pages.Product.ToggleRiskLevel index)))
                        ] []
                , text "Normal and High risk levels"
                ]
        , input [ class "uk-input"
                , value product.riskLabel
                , placeholder "Label"
                , disabled (not hasRiskLevels)
                , onInput (GroupMsg << Pages.Group.ProductMsg << Pages.Product.SetRiskLabel index)
                ] []
        ]


benefitTabs : Int -> Product -> Html Msg
benefitTabs index product =
    ul [ class "uk-child-width-expand", attribute "uk-tab" "1" ]
       (List.map (benefitTab index product.focusedBenefit) product.benefits)

benefitTab : Int -> Int -> Tier -> Html Msg
benefitTab productIndex benefitIndex benefit =
    let
        tabClass key =
            if benefitIndex == key then
                "uk-active"
            else
                ""
    in
    li [ class (tabClass benefit.key)
       , onClick (GroupMsg (Pages.Group.ProductMsg (Pages.Product.FocusBenefit productIndex benefit.key)))
       ]
       [ a [] [text benefit.display] ]

headerRow : Int -> Product -> Html Msg
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
       , th [ rowspan ((List.length product.ages) + 2)
            , style [ ("vertical-align", "top")
                    , ("width",          "180px")
                    ]
            ]
            [ deductionPriceTable index product
            ]
       ]

deductionPriceTable : Int -> Product -> Html Msg
deductionPriceTable index product =
    case product.focus of
        Nothing ->
            text ""
        Just (ageIndex, coverage, risk) ->
            let
                ageTier =
                    product.ages
                    |> (List.drop ageIndex)
                    |> List.head
                    |> Maybe.withDefault (Tier "ERROR" -1)
                coverageDisplay =
                    case coverage of
                        Employee -> "EE"
                        PlusKids -> "+CH"
                        PlusSpouse -> "+SP"
                        PlusFamily -> "+FAM"
                riskDisplay =
                    case risk of
                        NormalRisk -> "Normal Risk"
                        HighRisk   -> "High Risk"
            in
            div []
                [ div []
                      [ h2 [] [ text "Deductions"]
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
                , deductionPriceRow (index, ageIndex, coverage, risk) product Weekly
                , deductionPriceRow (index, ageIndex, coverage, risk) product BiWeekly
                , deductionPriceRow (index, ageIndex, coverage, risk) product SemiMonthly
                , deductionPriceRow (index, ageIndex, coverage, risk) product Monthly
                ]

deductionModeLabel : DeductionMode -> String
deductionModeLabel deductMode =
    case deductMode of
        Weekly -> "Weekly"
        BiWeekly -> "Bi-weekly"
        SemiMonthly -> "Semi-monthly"
        Monthly -> "Monthly"

getDeduction : (Int, Coverage, RiskLevel) -> Product -> DeductionMode -> DecimalField
getDeduction (ageIndex, coverage, riskLevel) product deductMode =
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
    monthly.value * 12 / perYear
    |> DecimalField.fromFloat


deductionPriceRow : (Int, Int, Coverage, RiskLevel) -> Product -> DeductionMode -> Html Msg
deductionPriceRow (productIndex, ageIndex, coverage, risk) product deductMode =
    if deductMode == Monthly || product.explicitDeductions then
        explicitDeductionPriceRow (productIndex, ageIndex, coverage, risk) product deductMode
    else
        let
            monthly =
                getDeduction (ageIndex, coverage, risk) product Monthly
            calculated =
                calculateDeduction monthly deductMode
        in
        div []
            [ label []
                    [ text (deductionModeLabel deductMode) ]
            , input [ value (DecimalField.toFixed calculated.value 2)
                    , disabled True
                    ]
                    []
            ]

explicitDeductionPriceRow : (Int, Int, Coverage, RiskLevel) -> Product -> DeductionMode -> Html Msg
explicitDeductionPriceRow (productIndex, ageIndex, coverage, risk) product deductMode =
    let
        price =
            getDeduction (ageIndex, coverage, risk) product deductMode
    in
    div []
        [ label []
                [ text (deductionModeLabel deductMode) ]
        , input [ value (DecimalField.inputValue price)
                , onInput (GroupMsg << Pages.Group.ProductMsg << Pages.Product.SetPrice productIndex ageIndex coverage deductMode risk)
                ]
                []
        ]

tableBody : Int -> Product -> List (Html Msg)
tableBody index product =
  List.map (renderBenefitRow index product) product.ages
  ++
  [tr []
      ([th []
           [ span [ attribute "uk-icon" "plus-circle"
                  , onClick (GroupMsg (Pages.Group.ProductMsg (Pages.Product.AddAgeTier index)))
                  , title "Add Age Tier"
                  ]
                  []
           ]
      ]
      ++
      List.map (\_ -> td [] []) product.benefits
      ++
      [td [] []]
      )
  ]

renderBenefitRow : Int -> Product -> Tier -> Html Msg
renderBenefitRow index product ageTier =
    tr []
       ( [ td []
              [ input [ class "uk-input"
                      , value ageTier.display
                      , onInput (GroupMsg << Pages.Group.ProductMsg << Pages.Product.SetTierDisplay index ageTier.key)
                      ] []
              ]
         ]
         ++
         (List.map (renderCell index ageTier product.focusedBenefit product.pricing product.riskLevels)
                   [Employee, PlusKids, PlusSpouse, PlusFamily])
         ++
         [ td []
              [ span [ attribute "uk-icon" "close"
                     , onClick (GroupMsg (Pages.Group.ProductMsg (Pages.Product.ConfirmRemoveTier index AgeTier ageTier.key)))
                     , title "Remove Age Tier"
                     ] []
              ]
         ]
       )

renderCell : Int -> Tier -> Int -> EveryDict Coverage PriceGrid -> List RiskLevel -> Coverage -> Html Msg
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

renderInput : Int -> Int -> Coverage -> DeductionMode -> (RiskLevel -> DecimalField) -> Bool -> RiskLevel -> Html Msg
renderInput productIndex ageIndex coverage deductMode getPrice multiRisk risk =
    let
        className =
            if multiRisk then
                "uk-width-1-2"
            else
                ""
    in
    div [ class className
        , style [ ("float", "left") ]
        ]
        [ input [ class "uk-input"
                , value (DecimalField.inputValue (getPrice risk))
                , onInput (GroupMsg << Pages.Group.ProductMsg << Pages.Product.SetPrice productIndex ageIndex coverage deductMode risk)
                , onFocus (GroupMsg (Pages.Group.ProductMsg (Pages.Product.SetFocus productIndex ageIndex coverage risk)))
                ]
                []
        ]

renderModal : Pages.Product.Model -> Html Msg
renderModal model =
    case model.removeTier of
        Nothing ->
            text ""
        Just (productIndex, tierType, tierIndex) ->
            let
                product =
                    model.products
                    |> List.Extra.getAt productIndex
                    |> Maybe.withDefault Models.Product.init
                tierTypeDisplay =
                    case tierType of
                        AgeTier -> "Age Tier"
                        BenefitTier -> "Benefit Tier"
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
                        AgeTier -> " (across all benefit tiers)"
                        BenefitTier -> ""
            in
            div [ class "uk-modal uk-open"
                , attribute "uk-modal" ""
                , style [ ("display", "block") ]
                ]
                [ div [ class "uk-modal-dialog uk-modal-body" ]
                      [ h2 [ class "uk-modal-title" ]
                           [ text "Remove Tier" ]
                      , p []
                          [ text ("You are removing the " ++
                                  tierTypeDisplay ++
                                  " named \"" ++
                                  tierDisplay ++
                                  "\"" ++
                                  tierExtraDisplay ++
                                  " and deleting all associated pricing.  This cannot be undone.  Are you sure you want to continue?")
                          ]
                      , p [ class "uk-text-right" ]
                          [ button [ class "uk-button uk-button-default uk-modal-close"
                                   , type_ "button"
                                   , onClick (GroupMsg (Pages.Group.ProductMsg Pages.Product.CancelRemoveTier))
                                   ]
                                   [ text "Cancel" ]
                          , button [ class "uk-button uk-button-primary"
                                   , type_ "button"
                                   , onClick (GroupMsg (Pages.Group.ProductMsg Pages.Product.RemoveTier))
                                   ]
                                   [ text "Delete" ]
                          ]
                      ]
                ]
