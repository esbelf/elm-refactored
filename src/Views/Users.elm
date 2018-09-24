module Views.Users exposing (view)

import Msg exposing (..)
import Pages.Users exposing (Model)
import Models.User exposing (User)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (attribute, class, href, name, type_, value, placeholder)

view : Model -> Html Msg
view model =
  div [ class "uk-margin" ]
    [ h1 [] [ text "Users" ]
    , div []
      [ p [] [ text model.errorMsg ]
      ]
    , div []
      [ table [ class "uk-table uk-table-striped" ]
        [ thead []
          [ tr []
            [ th [] [ text "Email" ]
            , th [] [ ]
            ]
          ]
        , tbody []
          (viewUserList model.users)
        ]
      ]


    ]

viewUserList : List User -> List (Html Msg)
viewUserList users =
  List.map viewUser users

viewUser : User -> Html Msg
viewUser user =
  tr []
    [ td [] [ text user.email ]
    , td []
      [ button
        [ class "uk-button uk-button-danger"
        , type_ "button"
        , onClick (UsersMsg (Pages.Users.DeleteUserRequest user.id) )
        ] [ text "Delete" ]
      ]
    ]
