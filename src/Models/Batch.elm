module Models.Batch exposing (Batch, BatchForm)


type alias Batch =
    { id : Int
    , group_id : Int
    , group_name : String
    , user_id : Int
    , user_email : String
    , census_count : Int
    , start_date : String
    , created_at : String
    }


type alias BatchForm =
    { startDate : String
    , fileData : String
    , fileName : String
    , groupId : Int
    }
