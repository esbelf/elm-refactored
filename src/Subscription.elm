module Subscription exposing (pageSubscriptions)

import Components.Group
import Model exposing (Model, PageState(..), getPage)
import Msg exposing (..)
import Page
import Pages.CreateBatch
import Pages.CreateGroup
import Pages.EditGroup
import Port


pageSubscriptions : Model -> Sub Msg
pageSubscriptions model =
    let
        page =
            getPage model.pageState
    in
    case page of
        Page.CreateBatch _ ->
            Port.fileContentRead (CreateBatchMsg << Pages.CreateBatch.FileRead)

        Page.CreateGroup _ ->
            Port.fileContentRead (CreateGroupMsg << Pages.CreateGroup.GroupMsg << Components.Group.FileRead)

        Page.EditGroup _ ->
            Port.fileContentRead (EditGroupMsg << Pages.EditGroup.GroupMsg << Components.Group.FileRead)

        _ ->
            Sub.none
