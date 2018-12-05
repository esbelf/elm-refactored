module Models.Storage exposing (StorageModel)

import Time exposing (Posix)


type alias StorageModel =
    { token : String
    , exp : Int
    }
