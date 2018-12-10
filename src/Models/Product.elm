module Models.Product exposing (AgePricing, Coverage(..), DeductionDict, DeductionMode(..), PriceGrid, PriceMethod(..), Pricing, PricingDict, Product, RiskDict, RiskLevel(..), Tier, TierType(..), coverageToKey, deductionDictFromList, deductionModeToKey, emptyDeductionDict, emptyRiskDict, init, initPricingDict, initTier, pricingDictFromList, riskDictFromList, riskLevelToKey, riskLevelToLabel, riskLevelToValue, stringToRiskLevel)

import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Helpers.DecimalField exposing (DecimalField)


type alias Product =
    { name : String
    , pricing : PricingDict
    , benefits : List Tier
    , ages : List Tier
    , riskLabel : String
    , riskLevels : List RiskLevel
    , focusedBenefit : Int
    , explicitDeductions : Bool
    , focus : Maybe ( Int, Coverage, RiskLevel )
    }


init : Product
init =
    { name = ""
    , pricing = initPricingDict
    , benefits = initTier "One Benefit"
    , ages = initTier "One Age Range"
    , riskLabel = ""
    , riskLevels = [ NormalRisk ]
    , focusedBenefit = 0
    , explicitDeductions = False
    , focus = Nothing
    }


initPricingDict : PricingDict
initPricingDict =
    AnyDict.fromList coverageToKey
        [ ( Employee, Dict.empty )
        , ( PlusSpouse, Dict.empty )
        , ( PlusKids, Dict.empty )
        , ( PlusFamily, Dict.empty )
        ]


initTier : String -> List Tier
initTier name =
    [ Tier name 0 ]


type alias Pricing =
    { benefits : List Tier
    , ages : List Tier
    , prices : PriceGrid
    }


type alias PricingDict =
    AnyDict String Coverage PriceGrid


type alias PriceGrid =
    Dict Int AgePricing


type alias AgePricing =
    Dict Int DeductionDict


type alias DeductionDict =
    AnyDict String DeductionMode RiskDict


type alias RiskDict =
    AnyDict String RiskLevel DecimalField


type TierType
    = BenefitTier
    | AgeTier


type alias Tier =
    { display : String
    , key : Int
    }


riskLevelToValue : RiskLevel -> String
riskLevelToValue riskLevel =
    case riskLevel of
        NormalRisk ->
            "normalrisk"

        HighRisk ->
            "highrisk"


riskLevelToLabel : RiskLevel -> String
riskLevelToLabel riskLevel =
    case riskLevel of
        NormalRisk ->
            "Normal Risk"

        HighRisk ->
            "High Risk"


stringToRiskLevel : String -> Result String RiskLevel
stringToRiskLevel str =
    case str of
        "normalrisk" ->
            Ok NormalRisk

        "highrisk" ->
            Ok HighRisk

        _ ->
            Err <| "Unknown risklevel" ++ str


type RiskLevel
    = NormalRisk
    | HighRisk


type Coverage
    = Employee
    | PlusSpouse
    | PlusKids
    | PlusFamily


type PriceMethod
    = Calculated
    | Explicit


type DeductionMode
    = Weekly
    | BiWeekly
    | SemiMonthly
    | Monthly


{-| The \*toKey functions should not be exported -- internal implementation only.
these functions should only be needed to create new AnyDicts, and we provide wrapper
methods for `empty` and `fromList`. Could add `singleton` if needed.
-}
coverageToKey : Coverage -> String
coverageToKey coverage =
    case coverage of
        Employee ->
            "EE"

        PlusKids ->
            "CH"

        PlusSpouse ->
            "SP"

        PlusFamily ->
            "FM"


deductionModeToKey : DeductionMode -> String
deductionModeToKey deductionMode =
    case deductionMode of
        Weekly ->
            "W"

        BiWeekly ->
            "B"

        SemiMonthly ->
            "S"

        Monthly ->
            "M"


riskLevelToKey : RiskLevel -> String
riskLevelToKey riskLevel =
    case riskLevel of
        NormalRisk ->
            "N"

        HighRisk ->
            "H"


emptyDeductionDict : DeductionDict
emptyDeductionDict =
    AnyDict.empty deductionModeToKey


emptyRiskDict : RiskDict
emptyRiskDict =
    AnyDict.empty riskLevelToKey


pricingDictFromList : List ( Coverage, PriceGrid ) -> PricingDict
pricingDictFromList =
    AnyDict.fromList coverageToKey


deductionDictFromList : List ( DeductionMode, RiskDict ) -> DeductionDict
deductionDictFromList =
    AnyDict.fromList deductionModeToKey


riskDictFromList : List ( RiskLevel, DecimalField ) -> RiskDict
riskDictFromList =
    AnyDict.fromList riskLevelToKey
