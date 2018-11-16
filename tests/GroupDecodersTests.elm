module GroupDecodersTests exposing (newGroupEncode, noIdDecoder, normalDecoder, simpleEncode)

import Expect exposing (Expectation)
import Json.Decode as Decode
import Json.Encode as Encode
import Models.Group as Group exposing (FormType(..), Group)
import Requests.Group
import Test exposing (..)


simpleGroup : Group
simpleGroup =
    { id = Just 1
    , name = "IBEW 47 - Class 2"
    , disclosure = ""
    , form_type = Ibew
    , employee_contribution = ""
    , payment_mode = 12
    , products = []
    }


normalDecoder : Test
normalDecoder =
    test "decodes 'normal' group" <|
        \_ ->
            let
                input =
                    """
                    {
                      "id": "1",
                      "type": "groups",
                      "attributes": {
                        "name": "IBEW 47 - Class 2",
                        "disclosure": null,
                        "form_type": "ibew",
                        "payment_mode": 12,
                        "created_at": "2018-11-14T12:52:49.778Z"
                      }
                    }
                    """

                decodedOutput =
                    Decode.decodeString Requests.Group.groupDecoder input
            in
            Expect.equal decodedOutput
                (Ok simpleGroup)


noIdDecoder : Test
noIdDecoder =
    test "group without id fails to decode" <|
        \_ ->
            let
                input =
                    """
                    {
                      "id": null,
                      "type": "groups",
                      "attributes": {
                        "name": "IBEW 47 - Class 2",
                        "disclosure": null,
                        "form_type": "ibew",
                        "payment_mode": 12,
                        "created_at": "2018-11-14T12:52:49.778Z"
                      }
                    }
                    """

                decodedOutput =
                    Decode.decodeString Requests.Group.groupDecoder input
            in
            Expect.err decodedOutput


simpleEncode : Test
simpleEncode =
    test "can encode simple group" <|
        \_ ->
            let
                jsonOutput =
                    Requests.Group.groupEncoder simpleGroup
                        |> Encode.encode 2

                expected =
                    """{
  "id": 1,
  "name": "IBEW 47 - Class 2",
  "disclosure": "",
  "form_type": "ibew",
  "employee_contribution": "",
  "payment_mode": 12,
  "product_pricing": {
    "products": []
  }
}"""
            in
            Expect.equal jsonOutput expected


newGroupEncode : Test
newGroupEncode =
    test "can encode new group (id = Nothing)" <|
        \_ ->
            let
                newGroup =
                    { simpleGroup | id = Nothing }

                jsonOutput =
                    Requests.Group.groupEncoder newGroup
                        |> Encode.encode 2

                expected =
                    """{
  "name": "IBEW 47 - Class 2",
  "disclosure": "",
  "form_type": "ibew",
  "employee_contribution": "",
  "payment_mode": 12,
  "product_pricing": {
    "products": []
  }
}"""
            in
            Expect.equal jsonOutput expected



-- roundTrip : Test
-- roundTrip =
--     test "object can encode and decode back into itself" <|
--         \_ ->
--             simpleGroup
--                 |> Requests.Group.groupEncoder
--                 |> Decode.decodeValue Requests.Group.groupDecoder
--                 |> Expect.equal (Ok simpleGroup)
--
-- suite : Test
-- suite =
--     describe "Group JSON Encoder / Decoders"
--         [ describe "Requests.Group.groupDecoder"
--             [ normalDecoder, noIdDecoder ]
--         , describe "Round trip"
--             [ roundTrip ]
--         ]
