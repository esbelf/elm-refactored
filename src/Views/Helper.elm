module Views.Helper exposing (convertMsgHtml, unionSelectOptions)

import Html exposing (..)
import Html.Attributes exposing (selected, value)


convertMsgHtml : (subMsg -> mainMsg) -> Html subMsg -> Html mainMsg
convertMsgHtml toMsg subMsgHtml =
    Html.map toMsg subMsgHtml


{-| Make a list of <option> tags to use with a <select> element to choose a value for a union type.
Sets selected for the currentValue.

Pass a list of all possible values for a type, functions to turn the type into
computer- and human- friendly forms, and the current Value.

-}
unionSelectOptions : List a -> (a -> String) -> (a -> String) -> a -> List (Html msg)
unionSelectOptions values toId toLabel currentValue =
    let
        optionize val =
            option
                ([ (value << toId) val ]
                    ++ (if val == currentValue then
                            [ selected True ]

                        else
                            []
                       )
                )
                [ (text << toLabel) val ]
    in
    List.map optionize values
