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
    | Ibew
    | HealthSuppOnlyProduct


{-| Annoying that Elm can't provide us all possible values for a union type.
Keep this in sync with all possible values of FormType.
-}
allFormTypes : List FormType
allFormTypes =
    [ Life
    , Ibew
    , HealthSuppOnlyProduct
    ]


stringToFormType : String -> Result String FormType
stringToFormType str =
    case str of
        "life" ->
            Ok Life

        "ibew" ->
            Ok Ibew

        "health_supp_only_product" ->
            Ok HealthSuppOnlyProduct

        _ ->
            Err <| "Unknown formtype" ++ str


formTypeToString : FormType -> String
formTypeToString formType =
    case formType of
        Life ->
            "life"

        Ibew ->
            "ibew"

        HealthSuppOnlyProduct ->
            "health_supp_only_product"


formTypeToLabel : FormType -> String
formTypeToLabel formType =
    case formType of
        Life ->
            "Life"

        Ibew ->
            "Ibew"

        HealthSuppOnlyProduct ->
            "Health Supply Only Product"
