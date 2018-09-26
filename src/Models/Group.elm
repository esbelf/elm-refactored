module Models.Group exposing (Group, init)

type alias Group =
  { id : Int
  , name : String
  , disclosure : String
  , form_type : String
  , payment_mode : Int
  }

init : Group
init =
  { id = 0
  , name = ""
  , disclosure = ""
  , form_type = ""
  , payment_mode = 0
  }
