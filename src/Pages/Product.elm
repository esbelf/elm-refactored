module Pages.Product exposing (Model, Msg(..), addAgeTier, addBenefitTier, addProduct, addTier, cancelRemoveTier, confirmRemoveTier, focusBenefit, init, rekey, removeAgePricing, removeAgePricing_, removeBenefitPricing, removeBenefitPricing_, removeBenefitPricing__, removeTier, renameBaseTier, setBenefitDisplay, setFocus, setName, setPrice, setRiskLabel, setTierDisplay, toggleExplicitDeductions, toggleRiskLevel, update)

import Dict exposing (Dict)
import EveryDict exposing (EveryDict)
import Helpers.DecimalField
import List.Extra exposing (removeAt, updateAt)
import Models.Product exposing (AgePricing, Coverage(..), DeductionMode, PriceGrid, Product, RiskLevel(..), Tier, TierType(..), init)


type alias Model =
    { products : List Product
    , removeTier : Maybe ( Int, TierType, Int )
    }


init : Model
init =
    { products = []
    , removeTier = Nothing
    }


type Msg
    = None
    | AddProduct
    | ToggleExplicitDeductions Int
    | ToggleRiskLevel Int
    | SetRiskLabel Int String
    | FocusBenefit Int Int
    | SetProductName Int String
    | SetPrice Int Int Coverage DeductionMode RiskLevel String
    | SetFocus Int Int Coverage RiskLevel
    | SetBenefitDisplay Int Int String
    | SetTierDisplay Int Int String
    | AddBenefitTier Int
    | AddAgeTier Int
    | ConfirmRemoveTier Int TierType Int
    | CancelRemoveTier
    | RemoveTier


update : Msg -> Model -> String -> ( Model, Cmd Msg )
update msg model token =
    case msg of
        None ->
            ( model, Cmd.none )

        AddProduct ->
            ( addProduct model, Cmd.none )

        ToggleExplicitDeductions index ->
            ( toggleExplicitDeductions model index, Cmd.none )

        ToggleRiskLevel index ->
            ( toggleRiskLevel model index, Cmd.none )

        SetRiskLabel index label ->
            ( setRiskLabel model index label, Cmd.none )

        FocusBenefit productIndex benefitIndex ->
            ( focusBenefit model productIndex benefitIndex, Cmd.none )

        SetProductName index name ->
            ( setName model index name, Cmd.none )

        SetPrice productIndex ageIndex coverage deductMode risk value ->
            ( setPrice model productIndex ageIndex coverage deductMode risk value, Cmd.none )

        SetFocus productIndex ageIndex coverage riskLevel ->
            ( setFocus model productIndex ageIndex coverage riskLevel, Cmd.none )

        SetBenefitDisplay productIndex tierIndex value ->
            ( setBenefitDisplay model productIndex tierIndex value, Cmd.none )

        SetTierDisplay productIndex tierIndex value ->
            ( setTierDisplay model productIndex tierIndex value, Cmd.none )

        AddBenefitTier index ->
            ( addBenefitTier model index, Cmd.none )

        AddAgeTier index ->
            ( addAgeTier model index, Cmd.none )

        ConfirmRemoveTier productIndex tierType tierIndex ->
            ( confirmRemoveTier model productIndex tierType tierIndex, Cmd.none )

        CancelRemoveTier ->
            ( cancelRemoveTier model, Cmd.none )

        RemoveTier ->
            ( removeTier model, Cmd.none )


addProduct : Model -> Model
addProduct model =
    { model | products = model.products ++ [ Models.Product.init ] }


toggleExplicitDeductions : Model -> Int -> Model
toggleExplicitDeductions model index =
    let
        setProduct p =
            { p | explicitDeductions = not p.explicitDeductions }
    in
    { model | products = updateAt index setProduct model.products }


toggleRiskLevel : Model -> Int -> Model
toggleRiskLevel model index =
    let
        setProduct p =
            let
                ( riskLevels, riskLabel ) =
                    if List.length p.riskLevels > 1 then
                        ( [ NormalRisk ], "" )

                    else
                        ( [ NormalRisk, HighRisk ], p.riskLabel )
            in
            { p | riskLevels = riskLevels, riskLabel = riskLabel }
    in
    { model | products = updateAt index setProduct model.products }


setRiskLabel : Model -> Int -> String -> Model
setRiskLabel model index label =
    let
        setProduct p =
            { p | riskLabel = label }
    in
    { model | products = updateAt index setProduct model.products }


focusBenefit : Model -> Int -> Int -> Model
focusBenefit model productIndex benefitIndex =
    let
        setFocusedBenefit p =
            { p | focusedBenefit = benefitIndex }
    in
    { model | products = updateAt productIndex setFocusedBenefit model.products }


setName : Model -> Int -> String -> Model
setName model index name =
    let
        setProduct p =
            { p | name = name }
    in
    { model | products = updateAt index setProduct model.products }


setPrice : Model -> Int -> Int -> Coverage -> DeductionMode -> RiskLevel -> String -> Model
setPrice model productIndex ageIndex coverage deductMode riskLevel value =
    let
        setProduct p =
            let
                ( coverage, risk ) =
                    case p.focus of
                        Nothing ->
                            ( Employee, NormalRisk )

                        Just ( _, coverage, risk ) ->
                            ( coverage, risk )

                -- deduct mode prices -> risk level price
                setRiskLevelPrice prices =
                    let
                        existing =
                            EveryDict.get riskLevel prices
                                |> Maybe.withDefault (Helpers.DecimalField.fromFloat 0.0)
                                |> .value
                    in
                    EveryDict.update riskLevel (\_ -> Just (Helpers.DecimalField.fromString value existing)) prices

                -- benefit prices -> deduct mode prices
                setDeductModePrices prices =
                    let
                        update =
                            \prices ->
                                case prices of
                                    Nothing ->
                                        Just (setRiskLevelPrice EveryDict.empty)

                                    Just p ->
                                        Just (setRiskLevelPrice p)
                    in
                    EveryDict.update deductMode update prices

                -- age prices -> benefit prices
                setBenefitPrices benefitPrices =
                    let
                        update =
                            \prices ->
                                case prices of
                                    Nothing ->
                                        Just (setDeductModePrices EveryDict.empty)

                                    Just d ->
                                        Just (setDeductModePrices d)
                    in
                    Dict.update p.focusedBenefit update benefitPrices

                -- pricegrid -> age prices
                setAgePrices agePrices =
                    let
                        update =
                            \prices ->
                                case prices of
                                    Nothing ->
                                        Just (setBenefitPrices Dict.empty)

                                    Just d ->
                                        Just (setBenefitPrices d)
                    in
                    Dict.update ageIndex update agePrices

                -- coverage -> pricegrid
                setCoveragePrices pricegrid =
                    let
                        update =
                            \prices ->
                                case prices of
                                    Nothing ->
                                        Just (setAgePrices Dict.empty)

                                    Just d ->
                                        Just (setAgePrices d)
                    in
                    EveryDict.update coverage update pricegrid
            in
            { p | pricing = setCoveragePrices p.pricing }
    in
    { model | products = updateAt productIndex setProduct model.products }


setFocus : Model -> Int -> Int -> Coverage -> RiskLevel -> Model
setFocus model productIndex ageIndex coverage riskLevel =
    let
        setProduct p =
            { p | focus = Just ( ageIndex, coverage, riskLevel ) }
    in
    { model | products = updateAt productIndex setProduct model.products }


setBenefitDisplay : Model -> Int -> Int -> String -> Model
setBenefitDisplay model productIndex tierIndex value =
    let
        setProduct p =
            let
                setTier t =
                    { t | display = value }
            in
            { p | benefits = updateAt tierIndex setTier p.benefits }
    in
    { model | products = updateAt productIndex setProduct model.products }


setTierDisplay : Model -> Int -> Int -> String -> Model
setTierDisplay model productIndex tierIndex value =
    let
        setProduct p =
            let
                setTier t =
                    { t | display = value }
            in
            { p | ages = updateAt tierIndex setTier p.ages }
    in
    { model | products = updateAt productIndex setProduct model.products }


addTier : List Tier -> List Tier
addTier tiers =
    let
        index =
            List.length tiers

        tier =
            Tier
                ("Tier " ++ toString (index + 1))
                index
    in
    renameBaseTier tiers ++ [ tier ]


renameBaseTier : List Tier -> List Tier
renameBaseTier tiers =
    if List.length tiers == 1 then
        let
            rename t =
                { t | display = "Tier 1" }
        in
        updateAt 0 rename tiers

    else
        tiers


addBenefitTier : Model -> Int -> Model
addBenefitTier model index =
    let
        setProduct p =
            { p | benefits = addTier p.benefits }
    in
    { model | products = updateAt index setProduct model.products }


addAgeTier : Model -> Int -> Model
addAgeTier model index =
    let
        setProduct p =
            { p | ages = addTier p.ages }
    in
    { model | products = updateAt index setProduct model.products }


confirmRemoveTier : Model -> Int -> TierType -> Int -> Model
confirmRemoveTier model productIndex tierType tierIndex =
    { model | removeTier = Just ( productIndex, tierType, tierIndex ) }


cancelRemoveTier : Model -> Model
cancelRemoveTier model =
    { model | removeTier = Nothing }


removeTier : Model -> Model
removeTier model =
    let
        update products =
            case model.removeTier of
                Nothing ->
                    products

                Just ( productIndex, tierType, tierIndex ) ->
                    let
                        setProduct p =
                            case tierType of
                                BenefitTier ->
                                    { p
                                        | benefits = rekey (removeAt tierIndex p.benefits)
                                        , pricing = removeBenefitPricing tierIndex p.pricing
                                        , focusedBenefit = 0
                                        , focus = Nothing
                                    }

                                AgeTier ->
                                    { p
                                        | ages = rekey (removeAt tierIndex p.ages)
                                        , pricing = removeAgePricing tierIndex p.pricing
                                        , focusedBenefit = 0
                                        , focus = Nothing
                                    }
                    in
                    updateAt productIndex setProduct products
    in
    { model | products = update model.products, removeTier = Nothing }


rekey : List Tier -> List Tier
rekey tiers =
    List.indexedMap (\index -> \tier -> { tier | key = index }) tiers


removeBenefitPricing : Int -> EveryDict Coverage PriceGrid -> EveryDict Coverage PriceGrid
removeBenefitPricing index pricing =
    pricing
        |> EveryDict.toList
        |> List.map (\( coverage, priceGrid ) -> ( coverage, removeBenefitPricing_ index priceGrid ))
        |> EveryDict.fromList


removeBenefitPricing_ : Int -> PriceGrid -> PriceGrid
removeBenefitPricing_ index priceGrid =
    priceGrid
        |> Dict.toList
        |> List.map (\( age, pricing ) -> ( age, removeBenefitPricing__ index pricing ))
        |> Dict.fromList


removeBenefitPricing__ : Int -> AgePricing -> AgePricing
removeBenefitPricing__ index pricing =
    let
        benefits =
            Dict.keys pricing
                |> List.Extra.remove index
                |> List.indexedMap (,)
    in
    benefits
        |> List.map (\( is, was ) -> ( is, Dict.get was pricing |> Maybe.withDefault EveryDict.empty ))
        |> Dict.fromList


removeAgePricing : Int -> EveryDict Coverage PriceGrid -> EveryDict Coverage PriceGrid
removeAgePricing index pricing =
    pricing
        |> EveryDict.toList
        |> List.map (\( coverage, priceGrid ) -> ( coverage, removeAgePricing_ index priceGrid ))
        |> EveryDict.fromList


removeAgePricing_ : Int -> PriceGrid -> PriceGrid
removeAgePricing_ index priceGrid =
    let
        ages =
            Dict.keys priceGrid
                |> List.Extra.remove index
                |> List.indexedMap (,)
    in
    ages
        |> List.map (\( is, was ) -> ( is, Dict.get was priceGrid |> Maybe.withDefault Dict.empty ))
        |> Dict.fromList
