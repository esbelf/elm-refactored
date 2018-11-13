module Subscription exposing (pageSubscriptions)

import Debug
import Model exposing (Model, PageState(..), getPage)
import Msg exposing (..)
import Page
import Pages.Batches
import Port


pageSubscriptions : Model -> Sub Msg
pageSubscriptions model =
    let
        page =
            getPage model.pageState

        log =
            Debug.log "page Subscription" page
    in
    case page of
        Page.Batches _ ->
            Port.fileContentRead (BatchesMsg << Pages.Batches.FileRead)

        _ ->
            Sub.none
