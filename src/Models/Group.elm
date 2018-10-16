module Models.Group exposing (FormType, Group, init)

import Models.Product exposing (Product)


type alias Group =
    { id : Int
    , name : String
    , disclosure : String
    , form_type : String
    , employee_contribution : String
    , payment_mode : Int
    , products : List Product
    }


init : Group
init =
    { id = 0
    , name = ""
    , disclosure = ""
    , form_type = ""
    , employee_contribution = ""
    , payment_mode = 0
    , products = []
    }


type FormType
    = Life
    | Ibew
    | HealthSuppOnlyProduct
