module Requests.Product exposing (create, delete, get, getAll, update)

-- import Json.Encode as Encode

import Helpers.DecimalField
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


create : Product -> String -> Task Http.Error Product
create product token =
    Http.request
        { headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , body = productEncoder product
        , expect = Http.expectJson (dataDecoder productDecoder)
        , method = "POST"
        , timeout = Nothing
        , url = productsUrl
        , withCredentials = False
        }
        |> Http.toTask


update : Product -> String -> Task Http.Error Product
update product token =
    Http.request
        { headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , body = productEncoder product
        , expect = Http.expectJson (dataDecoder productDecoder)
        , method = "PATCH"
        , timeout = Nothing
        , url = productUrl product.id
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
        |> requiredAt [ "attributes", "rates" ] decodeColumns


decodeColumns : Decode.Decoder (List Models.Product.Column)
decodeColumns =
    Decode.list decodeColumn


decodeColumn : Decode.Decoder Models.Product.Column
decodeColumn =
    decode Models.Product.Column
        |> required "name" Decode.string
        |> optional "received" Decode.string ""
        |> optional "amount" Decode.string ""
        |> required "data" decodeDatas


decodeDatas : Decode.Decoder (List Models.Product.Data)
decodeDatas =
    Decode.list decodeData


decodeData : Decode.Decoder Models.Product.Data
decodeData =
    decode Models.Product.Data
        |> required "display" Decode.string
        |> required "min" Decode.int
        |> required "max" Decode.int
        |> required "cost" (Decode.dict decodeCosts)


decodeCosts : Decode.Decoder Models.Product.Cost
decodeCosts =
    decode Models.Product.Cost
        |> optional "normal" Decode.float 0.0
        |> optional "high" Decode.float 0.0


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
