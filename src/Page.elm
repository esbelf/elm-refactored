module Page exposing (Page(..))

import Pages.Batches as Batches
import Pages.CreateGroup as CreateGroup
import Pages.CreateProduct as CreateProduct
import Pages.EditGroup as EditGroup
import Pages.EditProduct as EditProduct
import Pages.Groups as Groups
import Pages.Login as Login
import Pages.Products as Products
import Pages.Users as Users


type Page
    = Blank
    | Error String
    | Home
    | Groups Groups.Model
    | EditGroup EditGroup.Model
    | CreateGroup CreateGroup.Model
    | Products Products.Model
    | EditProduct EditProduct.Model
    | CreateProduct CreateProduct.Model
    | Batches Batches.Model
    | Login Login.Model
    | Users Users.Model
