module Views.Login exposing (view)

import Html exposing (..)
import Html.Attributes exposing (attribute, class, href, name, placeholder, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Iso8601
import Models.Session exposing (Session)
import Msg exposing (..)
import Pages.Login exposing (Model)


view : Model -> Html Msg
view model =
    Html.form [ onSubmit (LoginMsg Pages.Login.Submit) ]
        [ h1 []
            [ text "Login Page" ]
        , showErrors model
        , div [ class "uk-child-width-1-3@s" ]
            [ div [ class "uk-margin" ]
                [ input
                    [ class "uk-input"
                    , name "email"
                    , type_ "input"
                    , value model.email
                    , placeholder "Email"
                    , onInput (LoginMsg << Pages.Login.SetEmail)
                    ]
                    []
                ]
            , div [ class "uk-margin" ]
                [ input
                    [ class "uk-input"
                    , name "password"
                    , type_ "password"
                    , value model.password
                    , placeholder "Password"
                    , onInput (LoginMsg << Pages.Login.SetPassword)
                    ]
                    []
                ]
            , div [ class "uk-margin" ]
                [ button
                    [ class "uk-button uk-button-primary"
                    , type_ "button"
                    , onClick (LoginMsg Pages.Login.Submit)
                    ]
                    [ text "Login" ]
                ]
            ]
        ]


showErrors : Model -> Html Msg
showErrors model =
    let
        errorDebugHtml =
            [ text "Error: "
            , text model.errorMsg
            ]

        sessionDebugHtml =
            model.session
                |> Maybe.map sessionDebug
                >> Maybe.withDefault missingSessionDebug
    in
    div [] (errorDebugHtml ++ sessionDebugHtml)


sessionDebug : Session -> List (Html Msg)
sessionDebug session =
    [ div []
        [ text "Session Token: "
        , text session.token
        ]
    , div []
        [ text "Session Exp: "
        , text (Iso8601.fromTime session.exp)
        ]
    ]


missingSessionDebug : List (Html Msg)
missingSessionDebug =
    [ div []
        [ text "[No session present]"
        ]
    ]
