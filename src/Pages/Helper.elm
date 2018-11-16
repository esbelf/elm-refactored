module Pages.Helper exposing (RecordWithID, RecordWithMaybeId, removeModelFromList, removeModelFromNullableIdList)


removeModelFromList : Int -> List (RecordWithID a) -> List (RecordWithID a)
removeModelFromList id =
    List.filter (\model -> model.id /= id)


removeModelFromNullableIdList : Maybe Int -> List (RecordWithMaybeId a) -> List (RecordWithMaybeId a)
removeModelFromNullableIdList id =
    List.filter (\model -> model.id /= id)


type alias RecordWithID a =
    { a | id : Int }


type alias RecordWithMaybeId a =
    { a | id : Maybe Int }
