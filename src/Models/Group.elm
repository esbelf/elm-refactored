module Models.Group exposing (Group, init, FormType)

import Models.Product exposing (Product)

type alias Group =
  { id : Int
  , name : String
  , disclosure : String
  , form_type : String
  , payment_mode : Int
  , products : List Product
  }

init : Group
init =
  { id = 0
  , name = ""
  , disclosure = ""
  , form_type = ""
  , payment_mode = 0
  , products = []
  }

type FormType
  = Chubb
  | Ibew
  | HealthSuppOnlyProduct
