module Pages.Helper exposing (RecordWithID, removeModelFromList)


removeModelFromList : Int -> List (RecordWithID a) -> List (RecordWithID a)
removeModelFromList id =
    List.filter (\model -> model.id /= id)


type alias RecordWithID a =
    { a | id : Int }
