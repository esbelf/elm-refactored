module Routes exposing (Route(..), href, routeToString)

import Html exposing (Attribute)
import Html.Attributes as Attr


type Route
    = NotFound
    | Home
    | Groups
    | EditGroup Int
    | CreateGroup
    | Batches
    | CreateBatch Int
    | Login
    | Logout
    | Users



-- VIEW HELPERS --


href : Route -> Attribute msg
href targetRoute =
    Attr.href (routeToString targetRoute)


routeToString : Route -> String
routeToString route =
    case route of
        Home ->
            ""

        Groups ->
            "groups"

        EditGroup id ->
            "groups/" ++ String.fromInt id

        CreateGroup ->
            "groups/new"

        Batches ->
            "batches"

        CreateBatch id ->
            "batches/new/" ++ String.fromInt id

        Users ->
            "users"

        Login ->
            "login"

        Logout ->
            "logout"

        NotFound ->
            "not-found"
