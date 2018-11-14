module Subscription exposing (pageSubscriptions)

import Model exposing (Model, PageState(..), getPage)
import Msg exposing (..)
import Page
import Pages.CreateBatch
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

        _ ->
            Sub.none
