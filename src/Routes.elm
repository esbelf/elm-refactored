module Routes exposing (Route(..))


type Route
    = NotFound
    | Home
    | Groups
    | EditGroup Int
    | CreateGroup
    | Products
    | EditProduct Int
    | CreateProduct
    | Batches
    | Login
    | Logout
    | Users
