module Models.Group exposing (FormType(..), Group, allFormTypes, formTypeToLabel, formTypeToString, init, stringToFormType)

import Models.Product exposing (Product)


type alias Group =
    { id : Maybe Int
    , name : String
    , disclosure : String
    , form_type : FormType
    , employee_contribution : String
    , payment_mode : Int
    , products : List Product
    }


init : Group
init =
    { id = Nothing
    , name = ""
    , disclosure = ""
    , form_type = Life
    , employee_contribution = ""
    , payment_mode = 0
    , products = []
    }


type FormType
    = Life
    | HealthSupp
    | LifeAndHealthSupp


{-| Annoying that Elm can't provide us all possible values for a union type.
Keep this in sync with all possible values of FormType.
-}
allFormTypes : List FormType
allFormTypes =
    [ Life
    , HealthSupp
    , LifeAndHealthSupp
    ]


stringToFormType : String -> Result String FormType
stringToFormType str =
    case str of
        "life" ->
            Ok Life

        "health_supp" ->
            Ok HealthSupp

        "life_and_health_supp" ->
            Ok LifeAndHealthSupp

        _ ->
            Err <| "Unknown formtype" ++ str


formTypeToString : FormType -> String
formTypeToString formType =
    case formType of
        Life ->
            "life"

        HealthSupp ->
            "health_supp"

        LifeAndHealthSupp ->
            "life_and_health_supp"


formTypeToLabel : FormType -> String
formTypeToLabel formType =
    case formType of
        Life ->
            "Life"

        HealthSupp ->
            "Health Supply Only Product"

        LifeAndHealthSupp ->
            "Life & Health Supp"
