module Requests.Group exposing (create, delete, get, getAll, groupDecoder, groupEncoder, groupsDecoder, groupsUrl, previewUrl, update)

-- import Date exposing (Date)

import Http
import Json.Decode as Decode exposing (..)
import Json.Decode.Pipeline exposing (custom, decode, optional, optionalAt, required, requiredAt)
import Json.Encode as Encode
import Models.Group exposing (FormType(..), Group, formTypeToString, stringToFormType)
import Requests.Base exposing (..)
import Requests.Product
import Task exposing (Task)


getAll : String -> Task Http.Error (List Group)
getAll token =
    Http.request
        { headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , body = Http.emptyBody
        , expect = Http.expectJson (dataDecoder groupsDecoder)
        , method = "GET"
        , timeout = Nothing
        , url = groupsUrl
        , withCredentials = False
        }
        |> Http.toTask


get : Int -> String -> Task Http.Error Group
get groupId token =
    Http.request
        { headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , body = Http.emptyBody
        , expect = Http.expectJson (dataDecoder groupDecoder)
        , method = "GET"
        , timeout = Nothing
        , url = groupUrl (Just groupId)
        , withCredentials = False
        }
        |> Http.toTask


update : Group -> String -> Task Http.Error Group
update =
    createOrUpdate


create : Group -> String -> Task Http.Error Group
create =
    createOrUpdate


createOrUpdate : Group -> String -> Task Http.Error Group
createOrUpdate group token =
    saveConfig group token
        |> Http.request
        |> Http.toTask


saveConfig group token =
    { headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
    , body = groupJsonBody group
    , expect = Http.expectJson (dataDecoder groupDecoder)
    , method = groupMethod group.id
    , timeout = Nothing
    , url = groupUrl group.id
    , withCredentials = False
    }


delete : Int -> String -> Task Http.Error String
delete groupId token =
    Http.request
        { headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , expect = Http.expectString
        , body = Http.emptyBody
        , method = "DELETE"
        , timeout = Nothing
        , url = groupUrl (Just groupId)
        , withCredentials = False
        }
        |> Http.toTask


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

        attributes =
            idAttr
                ++ [ ( "name", Encode.string group.name )
                   , ( "disclosure", Encode.string group.disclosure )
                   , ( "form_type", (formTypeToString >> Encode.string) group.form_type )
                   , ( "employee_contribution", Encode.string group.employee_contribution )
                   , ( "payment_mode", Encode.int group.payment_mode )
                   , ( "product_pricing", Requests.Product.encode group.products )
                   ]
    in
    Encode.object attributes


groupJsonBody : Group -> Http.Body
groupJsonBody =
    groupEncoder >> Http.jsonBody


groupsDecoder : Decode.Decoder (List Group)
groupsDecoder =
    Decode.list groupDecoder


groupDecoder : Decode.Decoder Group
groupDecoder =
    decode Group
        -- require groups coming from JSON to have ids defined.
        |> required "id" (Decode.map Just flexibleInt)
        |> requiredAt [ "attributes", "name" ] Decode.string
        |> optionalAt [ "attributes", "disclosure" ] Decode.string ""
        |> optionalAt [ "attributes", "form_type" ] parseFormType Life
        |> optionalAt [ "attributes", "employee_contribution" ] Decode.string ""
        |> optionalAt [ "attributes", "payment_mode" ] Decode.int 12
        |> optionalAt [ "attributes", "product_pricing", "products" ] Requests.Product.productsDecoder []


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
            groupsUrl ++ "/" ++ toString id

        Nothing ->
            groupsUrl


groupsUrl : String
groupsUrl =
    baseUrl ++ "/groups"



-- HELPERS


{-| Extract an int using [`String.toInt`](http://package.elm-lang.org/packages/elm-lang/core/latest/String#toInt)
import Json.Decode exposing (..)
""" { "field": "123" } """
|> decodeString (field "field" parseInt)
--> Ok 123
-}
parseInt : Decode.Decoder Int
parseInt =
    Decode.string |> Decode.andThen (String.toInt >> fromResult)


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


parseFormType : Decode.Decoder FormType
parseFormType =
    Decode.string |> Decode.andThen (stringToFormType >> fromResult)
