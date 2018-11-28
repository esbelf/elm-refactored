module Models.Group exposing (FormType(..), Group, Logo(..), allFormTypes, extractOldLogoUrl, formTypeToLabel, formTypeToString, init, revertLogoState, stringToFormType)

import Models.Product exposing (Product)


{-|

  - EmptyLogo - no file attached

  - AttachedLogo path- file attached & stored on server. String is path of logo for display.

  - UploadingLogo data filename maybeOldUrl - new file has been attached on client.
      - String: image data, base-64 encoded

      - String: file name

      - Maybe String: previously set url
          - in order to be able to reset to one of other states if user cancels file attachment.

-}
type Logo
    = EmptyLogo
    | AttachedLogo String
    | UploadingLogo String String (Maybe String)


type alias Group =
    { id : Maybe Int
    , name : String
    , disclosure : String
    , form_type : FormType
    , employee_contribution : String
    , payment_mode : Int
    , products : List Product
    , logo : Logo
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
    , logo = EmptyLogo
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


extractOldLogoUrl : Logo -> Maybe String
extractOldLogoUrl logo =
    case logo of
        EmptyLogo ->
            Nothing

        AttachedLogo url ->
            Just url

        UploadingLogo _ _ oldUrl ->
            oldUrl


revertLogoState : Logo -> Logo
revertLogoState logo =
    let
        maybeUrlToLogo maybeUrl =
            case maybeUrl of
                Just url ->
                    AttachedLogo url

                Nothing ->
                    EmptyLogo
    in
    case logo of
        EmptyLogo ->
            EmptyLogo

        AttachedLogo url ->
            AttachedLogo url

        UploadingLogo _ _ oldUrl ->
            maybeUrlToLogo oldUrl
