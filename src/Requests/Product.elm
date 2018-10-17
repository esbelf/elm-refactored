module Requests.Product exposing (delete, get, getAll, productDecoder, productEncoder, productUrl, productsDecoder, productsUrl)

-- import Json.Encode as Encode

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (custom, decode, optional, optionalAt, required, requiredAt)
import Json.Encode as Encode
import Models.Product exposing (Product)
import Requests.Base exposing (..)
import Task exposing (Task)



--- NEW STUFF ---


getAll : String -> Task Http.Error (List Product)
getAll token =
    Http.request
        { headers = [ Http.header "Authorization" ("Beader " ++ token) ]
        , body = Http.emptyBody
        , expect = Http.expectJson (dataDecoder productsDecoder)
        , method = "GET"
        , timeout = Nothing
        , url = productsUrl
        , withCredentials = False
        }
        |> Http.toTask


get : Int -> String -> Task Http.Error Product
get productId token =
    Http.request
        { headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , body = Http.emptyBody
        , expect = Http.expectJson (dataDecoder productDecoder)
        , method = "GET"
        , timeout = Nothing
        , url = productUrl productId
        , withCredentials = False
        }
        |> Http.toTask


delete : Int -> String -> Task Http.Error String
delete productId token =
    Http.request
        { headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , expect = Http.expectString
        , body = Http.emptyBody
        , method = "DELETE"
        , timeout = Nothing
        , url = productUrl productId
        , withCredentials = False
        }
        |> Http.toTask


productsDecoder : Decode.Decoder (List Product)
productsDecoder =
    Decode.list productDecoder


productDecoder : Decode.Decoder Product
productDecoder =
    decode Product
        |> custom (Decode.at [ "id" ] Decode.string |> Decode.andThen stringToInt)
        |> requiredAt [ "attributes", "name" ] Decode.string


productEncoder : Product -> Http.Body
productEncoder product =
    let
        attributes =
            [ ( "id", Encode.int product.id )
            , ( "name", Encode.string product.name )
            ]
    in
    Encode.object attributes
        |> Http.jsonBody


productsUrl : String
productsUrl =
    baseUrl ++ "/products"


productUrl : Int -> String
productUrl productId =
    productsUrl ++ "/" ++ toString productId
