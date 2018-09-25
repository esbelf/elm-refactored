module Pages.Helper exposing (..)

removeModelFromList : Int -> List (RecordWithID a) -> List (RecordWithID a)
removeModelFromList id =
  List.filter (\model -> model.id /= id)

type alias RecordWithID a =
    { a | id : Int }

