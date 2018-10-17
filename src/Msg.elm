module Msg exposing (Msg(..))

import Http
import Pages.Batches
import Pages.CreateGroup
import Pages.CreateProduct
import Pages.EditGroup
import Pages.EditProduct
import Pages.Groups
import Pages.Login
import Pages.Products
import Pages.Users
import Routes exposing (Route)
import Time exposing (Time)


type Msg
    = SetRoute Route
    | RouteChanged Route
    | LogoutRequest
    | HomeMsg
    | GroupsLoaded (Result Http.Error Pages.Groups.Model)
    | GroupsMsg Pages.Groups.Msg
    | EditGroupLoaded (Result Http.Error Pages.EditGroup.Model)
    | EditGroupMsg Pages.EditGroup.Msg
    | CreateGroupMsg Pages.CreateGroup.Msg
    | ProductsLoaded (Result Http.Error Pages.Products.Model)
    | ProductsMsg Pages.Products.Msg
    | CreateProductMsg Pages.CreateProduct.Msg
    | EditProductLoaded (Result Http.Error Pages.EditProduct.Model)
    | EditProductMsg Pages.EditProduct.Msg
    | BatchesLoaded (Result Http.Error Pages.Batches.Model)
    | BatchesMsg Pages.Batches.Msg
    | BathesLoaded (Result Http.Error Pages.Batches.Model)
    | LoginMsg Pages.Login.Msg
    | UsersLoaded (Result Http.Error Pages.Users.Model)
    | UsersMsg Pages.Users.Msg
    | BatchFormRequest Int (Result Http.Error String)
    | TimeTick Time
