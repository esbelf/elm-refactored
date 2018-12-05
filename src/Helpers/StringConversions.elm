module Helpers.StringConversions exposing (fromHttpError, fromString, withUnionConstructor)

{-| From <https://github.com/NoRedInk/elm-string-conversions/blob/f30a60cac070b6dbdfee63a11e82b2389081c63a/src/String/Conversions.elm>
(package not yet updated to elm/http@2.0.0)
-}

import Http
import Json.Encode as Encode


{-| Nest some arguments under a tag, including parentheses when needed. Helpful for printing union type values.
withUnionConstructor "Ok" [ String.fromInt 1 ]
--> "Ok 1"
-}
withUnionConstructor : String -> List String -> String
withUnionConstructor tag args =
    let
        needsParens a =
            String.contains " " a
                && not (String.startsWith "{" a)
                && not (String.startsWith "(" a)
                && not (String.startsWith "[" a)
                && not (String.startsWith "\"" a)
                && not (String.startsWith "'" a)

        argsString =
            args
                |> List.map
                    (\arg ->
                        if needsParens arg then
                            "(" ++ arg ++ ")"

                        else
                            arg
                    )
                |> String.join " "
    in
    tag ++ " " ++ argsString


{-| Convert a String to a debugging version of that String.
fromString "hello "world""
--> ""hello \\"world\\"""
-}
fromString : String -> String
fromString string =
    Encode.encode 0 (Encode.string string)


{-| Convert an Http.Error to a String.
-}
fromHttpError : Http.Error -> String
fromHttpError error =
    case error of
        Http.BadUrl url ->
            withUnionConstructor "BadUrl" [ fromString url ]

        Http.Timeout ->
            withUnionConstructor "Timeout" []

        Http.NetworkError ->
            withUnionConstructor "NetworkError" []

        Http.BadStatus statusCode ->
            withUnionConstructor "BadStatus" [ String.fromInt statusCode ]

        Http.BadBody body ->
            withUnionConstructor "BadBody" [ fromString body ]
