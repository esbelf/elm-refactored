module Routes exposing (Route(..))


type Route
    = NotFound
    | Home
    | Groups
    | Group Int
    | Batches
    | Login
    | Logout
    | Users
