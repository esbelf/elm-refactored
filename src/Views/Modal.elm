module Views.Modal exposing (ModalButtonSpec, ModalButtonStyle(..), displayModal, modalButton)

import Html exposing (Html, button, div, h2, p, text)
import Html.Attributes exposing (attribute, class, style, type_)
import Html.Events exposing (onClick)


type ModalButtonStyle
    = ModalDefault
    | ModalPrimary
    | ModalSecondary
    | ModalDanger


type alias ModalButtonSpec msg =
    { label : String
    , action : msg
    , style : ModalButtonStyle
    }


modalButton : String -> msg -> ModalButtonStyle -> ModalButtonSpec msg
modalButton =
    ModalButtonSpec


displayModal : String -> Html msg -> List (ModalButtonSpec msg) -> Html msg
displayModal title content buttonList =
    div
        [ class "uk-modal uk-open"
        , attribute "uk-modal" ""
        , style "display" "block"
        ]
        [ div [ class "uk-modal-dialog uk-modal-body" ]
            [ h2 [ class "uk-modal-title" ]
                [ text title ]
            , content
            , p [ class "uk-text-right" ]
                (List.map displayButton buttonList)
            ]
        ]



-- PRIVATE


displayButton : ModalButtonSpec msg -> Html msg
displayButton buttonSpec =
    button
        [ buttonClass buttonSpec.style
        , type_ "button"
        , onClick buttonSpec.action
        ]
        [ text buttonSpec.label ]


buttonClass : ModalButtonStyle -> Html.Attribute msg
buttonClass style =
    case style of
        ModalDefault ->
            class "uk-button uk-button-default uk-modal-close"

        ModalPrimary ->
            class "uk-button uk-button-primary"

        ModalSecondary ->
            class "uk-button uk-button-secondary"

        ModalDanger ->
            class "uk-button uk-button-danger"
