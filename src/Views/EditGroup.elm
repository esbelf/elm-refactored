module Views.EditGroup exposing (view)

import Html exposing (..)
import Html.Attributes exposing (attribute, checked, class, href, name, placeholder, type_, value)
import Msg exposing (..)
import Pages.EditGroup
import Views.Components.Group
import Views.Helper exposing (convertMsgHtml)


view : Pages.EditGroup.Model -> Html Msg
view model =
    div [ class "uk-margin" ]
        [ h1 [] [ text "Edit Group" ]
        , convertMsgHtml EditGroupMsg (convertMsgHtml Pages.EditGroup.GroupMsg (Views.Group.view model.groupComponent))
        ]
