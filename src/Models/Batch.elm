module Models.Batch exposing (Batch)

type alias Batch =
  { id : Int
  , group_id : Int
  , user_id : Int
  , census_count : Int
  , start_date : String
  , created_at : String
  }

