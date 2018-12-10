module Requests.Group exposing (create, delete, duplicate, get, getAll, groupDecoder, groupEncoder, groupsDecoder, groupsUrl, previewUrl, update)

-- import Requests.Product

import Html.Attributes exposing (for)
import Http
import Json.Decode as Decode exposing (..)
import Json.Decode.Pipeline exposing (custom, hardcoded, optional, optionalAt, required, requiredAt)
import Json.Encode as Encode
import Models.Group exposing (FormType(..), Group, Logo(..), formTypeToString, stringToFormType)
import Requests.Base exposing (..)
import Task exposing (Task)


getAll : String -> (Result Http.Error (List Group) -> msg) -> Cmd msg
getAll token callback =
    Http.request
        { headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , body = Http.emptyBody
        , expect = Http.expectJson callback (dataDecoder groupsDecoder)
        , url = groupsUrl
        , method = "GET"
        , timeout = Nothing
        , tracker = Nothing
        }


get : Int -> String -> (Result Http.Error Group -> msg) -> Cmd msg
get groupId token callback =
    Http.request
        { headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , body = Http.emptyBody
        , expect = Http.expectJson callback (dataDecoder groupDecoder)
        , method = "GET"
        , timeout = Nothing
        , url = groupUrl (Just groupId)
        , tracker = Nothing
        }


update : Group -> String -> (Result Http.Error Group -> msg) -> Cmd msg
update =
    createOrUpdate


create : Group -> String -> (Result Http.Error Group -> msg) -> Cmd msg
create =
    createOrUpdate


createOrUpdate : Group -> String -> (Result Http.Error Group -> msg) -> Cmd msg
createOrUpdate group token callback =
    saveConfig group token callback
        |> Http.request


saveConfig : Group -> String -> (Result Http.Error Group -> msg) -> RequestConfig msg
saveConfig group token callback =
    { headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
    , body = groupJsonBody group
    , expect = Http.expectJson callback (dataDecoder groupDecoder)
    , method = groupMethod group.id
    , timeout = Nothing
    , url = groupUrl group.id
    , tracker = Nothing
    }


delete : Int -> String -> (Result Http.Error String -> msg) -> Cmd msg
delete groupId token callback =
    Http.request
        { headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , expect = Http.expectString callback
        , body = Http.emptyBody
        , method = "DELETE"
        , timeout = Nothing
        , url = groupUrl (Just groupId)
        , tracker = Nothing
        }


duplicate : Int -> String -> (Result Http.Error Group -> msg) -> Cmd msg
duplicate groupId token callback =
    let
        duplicateUrl =
            groupUrl (Just groupId) ++ "/duplicate"
    in
    Http.request
        { headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , expect = Http.expectJson callback (dataDecoder groupDecoder)
        , body = Http.emptyBody
        , method = "POST"
        , timeout = Nothing
        , url = duplicateUrl
        , tracker = Nothing
        }


previewUrl : Maybe Int -> String -> String
previewUrl groupId fileToken =
    groupUrl groupId ++ "/preview?file_token=" ++ fileToken


groupEncoder : Group -> Encode.Value
groupEncoder group =
    let
        idAttr =
            case group.id of
                Just actualId ->
                    [ ( "id", Encode.int actualId ) ]

                Nothing ->
                    []

        logoAttrs =
            case group.logo of
                UploadingLogo data fileName _ ->
                    [ ( "logo_data", Encode.string data )
                    , ( "logo_filename", Encode.string fileName )
                    ]

                _ ->
                    []

        attributes =
            idAttr
                ++ [ ( "name", Encode.string group.name )
                   , ( "disclosure", Encode.string group.disclosure )
                   , ( "form_type", (formTypeToString >> Encode.string) group.form_type )
                   , ( "employee_contribution", Encode.string group.employee_contribution )
                   , ( "payment_mode", Encode.int group.payment_mode )

                   -- , ( "product_pricing", Requests.Product.encode group.products )
                   ]
                ++ logoAttrs
    in
    Encode.object attributes


groupJsonBody : Group -> Http.Body
groupJsonBody =
    groupEncoder >> Http.jsonBody


groupsDecoder : Decoder (List Group)
groupsDecoder =
    Decode.list groupDecoder


groupDecoder : Decoder Group
groupDecoder =
    Decode.succeed Group
        -- require groups coming from JSON to have ids defined.
        |> required "id" (Decode.map Just flexibleInt)
        |> requiredAt [ "attributes", "name" ] Decode.string
        |> optionalAt [ "attributes", "disclosure" ] Decode.string ""
        |> optionalAt [ "attributes", "form_type" ] parseFormType Life
        |> optionalAt [ "attributes", "employee_contribution" ] Decode.string ""
        |> optionalAt [ "attributes", "payment_mode" ] Decode.int 12
        -- |> optionalAt [ "attributes", "product_pricing", "products" ] Requests.Product.productsDecoder []
        |> hardcoded []
        |> optionalAt [ "attributes", "logo_url" ] logoUrlDecoder EmptyLogo


groupMethod : Maybe Int -> String
groupMethod maybeGroupId =
    case maybeGroupId of
        Just _ ->
            "PATCH"

        Nothing ->
            "POST"


groupUrl : Maybe Int -> String
groupUrl maybeGroupId =
    case maybeGroupId of
        Just id ->
            groupsUrl ++ "/" ++ String.fromInt id

        Nothing ->
            groupsUrl


groupsUrl : String
groupsUrl =
    apiUrl ++ "/groups"



-- HELPERS


logoUrlDecoder : Decode.Decoder Logo
logoUrlDecoder =
    Decode.string |> Decode.andThen logoHelp


logoHelp : String -> Decoder Logo
logoHelp path =
    succeed <| AttachedLogo path


{-| Extract an int using [`String.toInt`](http://package.elm-lang.org/packages/elm-lang/core/latest/String#toInt)
import Json.Decode exposing (..)
""" { "field": "123" } """
|> decodeString (field "field" parseInt)
--> Ok 123
-}
parseInt : Decode.Decoder Int
parseInt =
    Decode.string |> Decode.andThen (String.toInt >> fromMaybe)


flexibleInt : Decode.Decoder Int
flexibleInt =
    Decode.oneOf [ parseInt, Decode.int ]


fromResult : Result String a -> Decode.Decoder a
fromResult result =
    case result of
        Ok successValue ->
            Decode.succeed successValue

        Err errorMessage ->
            Decode.fail errorMessage


fromMaybe : Maybe a -> Decode.Decoder a
fromMaybe maybeValue =
    case maybeValue of
        Just value ->
            Decode.succeed value

        Nothing ->
            Decode.fail "Got Nothing"


parseFormType : Decode.Decoder FormType
parseFormType =
    Decode.string |> Decode.andThen (stringToFormType >> fromResult)
