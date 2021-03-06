module Models.Product exposing (AgePricing, Coverage(..), DeductionMode(..), PriceGrid, PriceMethod(..), Pricing, Product, RiskLevel(..), Tier, TierType(..), init, initPricingDict, initTier, riskLevelToLabel, riskLevelToValue, stringToRiskLevel)

import Dict exposing (Dict)
import EveryDict exposing (EveryDict)
import Helpers.DecimalField exposing (DecimalField)


type alias Product =
    { name : String
    , pricing : EveryDict Coverage PriceGrid
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


initPricingDict : EveryDict Coverage PriceGrid
initPricingDict =
    EveryDict.fromList
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


type alias PriceGrid =
    Dict Int AgePricing



-- age tier


type alias AgePricing =
    Dict Int
        (-- benefit tier
         EveryDict DeductionMode (EveryDict RiskLevel DecimalField)
        )


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
