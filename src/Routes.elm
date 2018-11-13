module Routes exposing (Route(..))


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
