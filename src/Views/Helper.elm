module Views.Helper exposing (convertMsgHtml)

import Html exposing (..)


convertMsgHtml : (subMsg -> mainMsg) -> Html subMsg -> Html mainMsg
convertMsgHtml toMsg subMsgHtml =
    Html.map toMsg subMsgHtml
