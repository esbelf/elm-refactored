module Models.Group exposing (Group)

type alias Group =
  { id : Int
  , name : String
  , disclosure : String
  , form_type : String
  , payment_mode : Int
  }

