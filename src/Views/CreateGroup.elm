module Views.CreateGroup exposing (view)

import Html exposing (..)
import Html.Attributes exposing (attribute, checked, class, href, name, placeholder, type_, value)
import Msg exposing (..)
import Pages.CreateGroup
import Views.Group
import Views.Helper exposing (convertMsgHtml)


view : Pages.CreateGroup.Model -> Html Msg
view model =
    div [ class "uk-margin" ]
        [ h1 [] [ text "CreateGroup" ]
        , convertMsgHtml CreateGroupMsg (convertMsgHtml Pages.CreateGroup.GroupMsg (Views.Group.view model.groupComponent))
        ]
