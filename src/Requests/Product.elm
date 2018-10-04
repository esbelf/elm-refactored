module Requests.Product exposing (..)

import Json.Encode as Enc exposing (Value)
import Json.Decode as Dec exposing (Decoder, andThen, at, bool, dict, float, list, string, succeed)
import Json.Decode.Pipeline exposing (decode, required, optional, requiredAt, optionalAt, custom, hardcoded)

import Models.Product exposing (..)
import Pages.Product

import Helpers.DecimalField as DecimalField exposing (DecimalField)
import EveryDict exposing (EveryDict)
import Dict exposing (Dict)

--- ENCODING PARTS -----

encodeModel : Pages.Product.Model -> Value
encodeModel model =
    Enc.object <|
        [ ("products", encodeProductList model) ]

encodeProductList : Pages.Product.Model -> Value
encodeProductList model =
    Enc.list <| List.map encodeProduct model.products

coveragePricing : Coverage -> Product -> PriceGrid
coveragePricing coverage product =
    EveryDict.get coverage product.pricing
    |> Maybe.withDefault Dict.empty

encodeProduct : Product -> Value
encodeProduct product =
    let
        hasRisk =
            List.length product.riskLevels > 1
    in
    Enc.object <|
        [ ("name",     Enc.string product.name)
        , ("benefits", Enc.list <| List.map encodeTier product.benefits)
        , ("ages",     Enc.list <| List.map encodeTier product.ages)
        , ("risk",     Enc.object <|
            [ ("enabled", Enc.bool <| hasRisk)
            , ("label",   Enc.string <| product.riskLabel)
            ])
        , ("pricing",  Enc.object <|
            [ ("EE",   encodeAgePricing product (coveragePricing Employee   product))
            , ("SP",   encodeAgePricing product (coveragePricing PlusSpouse product))
            , ("CH",   encodeAgePricing product (coveragePricing PlusKids   product))
            , ("FM",   encodeAgePricing product (coveragePricing PlusFamily product))
            ])
        ]

encodeTier : Tier -> Value
encodeTier tier =
    Enc.object <|
        [ ("display", Enc.string tier.display)
        ]

encodeAgePricing : Product -> PriceGrid -> Value
encodeAgePricing product pricing =
    Enc.list <| List.map (encodeBenefitPricing product pricing) product.ages

encodeBenefitPricing : Product -> PriceGrid -> Tier -> Value
encodeBenefitPricing product pricing ageTier =
    let
        deductionModes =
            if product.explicitDeductions then
                [Monthly, SemiMonthly, BiWeekly, Weekly]
            else
                [Monthly]
    in
    Enc.list <| List.map (encodePricing (deductionModes, product.riskLevels) pricing ageTier.key) product.benefits


encodePricing : (List DeductionMode, List RiskLevel) -> PriceGrid -> Int -> Tier -> Value
encodePricing (deductModes, riskLevels) pricing ageIndex benefitTier =
    let
        deductions =
            List.map labeledDeductionMode deductModes
        risks =
            List.map labeledRiskLevel riskLevels
        agePrices =
            Dict.get ageIndex pricing
            |> Maybe.withDefault Dict.empty
        benePrices =
            Dict.get benefitTier.key agePrices
            |> Maybe.withDefault EveryDict.empty

        riskPrice deductMode riskLevel =
            let dmPrices =
                EveryDict.get deductMode benePrices
                |> Maybe.withDefault EveryDict.empty
            in
            EveryDict.get riskLevel dmPrices
            |> Maybe.withDefault (DecimalField.fromFloat 0.0)
            |> .value

        encodeDM (label, deductMode) =
            ( label
            , Enc.object <|
                List.map (\(l, r) -> (l, Enc.float <| riskPrice deductMode r) ) risks
            )

    in
    Enc.object <| List.map encodeDM deductions

labeledDeductionMode : DeductionMode -> (String, DeductionMode)
labeledDeductionMode mode =
    case mode of
        Monthly     -> ( "M", Monthly )
        SemiMonthly -> ( "S", SemiMonthly )
        BiWeekly    -> ( "B", BiWeekly )
        Weekly      -> ( "W", Weekly )

labeledRiskLevel : RiskLevel -> (String, RiskLevel)
labeledRiskLevel level =
    case level of
        NormalRisk -> ( "N", NormalRisk )
        HighRisk   -> ( "H", HighRisk )

--- DECODING PARTS -----

productsDecoder : Decoder (List Product)
productsDecoder =
  list productDecoder

productDecoder : Decoder Product
productDecoder =
  decode Product
    |> required "name" string
    |> required "pricing" decodePricing
    |> required "benefits" decodeTierList
    |> required "ages" decodeTierList
    |> requiredAt ["risk", "label"] string
    |> custom (
        at ["risk", "enabled"] bool
        |> andThen decodeRiskLevels
    )
    |> hardcoded 0
    |> custom (
        at ["pricing"] decodePricing
        |> andThen setExplicitDeduction
    )
    |> hardcoded Nothing


decodePricing : Decoder (EveryDict Coverage PriceGrid)
decodePricing =
    (dict decodePriceGrid)
    |> andThen (\d ->
        d
        |> transformPricing
        |> succeed
    )
transformPricing : Dict String PriceGrid -> EveryDict Coverage PriceGrid
transformPricing d =
    d
    |> Dict.toList
    |> List.map (\(c, a) -> (toCoverage c, a))
    |> EveryDict.fromList

decodePriceGrid : Decoder PriceGrid
decodePriceGrid =
    (list (list (dict (dict float))))
    |> andThen (\g ->
        g
        |> transformPriceGrid
        |> succeed
    )

transformPriceGrid_ : List (Dict String (Dict String Float)) -> Dict Int (EveryDict DeductionMode (EveryDict RiskLevel DecimalField))
transformPriceGrid_ l =
    l
    |> List.indexedMap (\index -> \d -> (index, transformDeductionMode d))
    |> Dict.fromList

transformPriceGrid : List (List (Dict String (Dict String Float))) -> PriceGrid
transformPriceGrid l =
    l
    |> List.indexedMap (\index -> \nested -> (index, transformPriceGrid_ nested))
    |> Dict.fromList

transformDeductionMode : Dict String (Dict String Float) -> EveryDict DeductionMode (EveryDict RiskLevel DecimalField)
transformDeductionMode d =
    d
    |> Dict.toList
    |> List.map (\(m, r) -> (toDeductionMode m, transformRisk r))
    |> EveryDict.fromList

decodeTierList : Decoder (List Tier)
decodeTierList =
    (list (dict string))
    |> andThen (
        \l ->
            l
            |> List.indexedMap (\i -> \t ->
                Tier
                    (Dict.get "display" t |> Maybe.withDefault "")
                    i
            )
            |> succeed
    )

decodeRiskLevels : Bool -> Decoder (List RiskLevel)
decodeRiskLevels flag =
    if flag then
        succeed [NormalRisk, HighRisk]
    else
        succeed [NormalRisk]


setExplicitDeduction : (EveryDict Coverage PriceGrid) -> Decoder Bool
setExplicitDeduction d =
    let
        deductionModes =
            (EveryDict.get Employee d)
            |> Maybe.withDefault Dict.empty
            |> Dict.get 0
            |> Maybe.withDefault Dict.empty
            |> Dict.get 0
            |> Maybe.withDefault EveryDict.empty
            |> EveryDict.keys
    in
    succeed (List.length deductionModes > 1)



toDeductionMode : String -> DeductionMode
toDeductionMode d =
    case d of
        "S" -> SemiMonthly
        "B" -> BiWeekly
        "W" -> Weekly
        _ -> Monthly

toCoverage : String -> Coverage
toCoverage c =
    case c of
        "SP" -> PlusSpouse
        "CH" -> PlusKids
        "FM" -> PlusFamily
        _ -> Employee

toRisk : String -> RiskLevel
toRisk r =
    case r of
        "H" -> HighRisk
        _ -> NormalRisk

transformRisk : Dict String Float -> EveryDict RiskLevel DecimalField
transformRisk r =
    r
    |> Dict.toList
    |> List.map (\(l, f) -> (toRisk l, DecimalField.fromFloat f))
    |> EveryDict.fromList