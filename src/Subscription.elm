module Subscription exposing (pageSubscriptions)

import Model exposing (Model, PageState(..), getPage)
import Msg exposing (..)
import Page
import Pages.CreateBatch
import Pages.GroupForm
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
            Sub.map CreateGroupMsg Pages.GroupForm.subscriptions

        Page.EditGroup _ ->
            Sub.map EditGroupMsg Pages.GroupForm.subscriptions

        _ ->
            Sub.none
