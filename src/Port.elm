port module Port exposing (fileContentRead, fileSelected, openWindow, removeStorage, setStorage)

import Json.Encode as Encode
import Models.FileData exposing (FileData)
import Models.Storage exposing (StorageModel)


port setStorage : StorageModel -> Cmd msg


port removeStorage : () -> Cmd msg


port openWindow : String -> Cmd msg



----- FILE UPLOAD --------


port fileSelected : String -> Cmd msg


port fileContentRead : (FileData -> msg) -> Sub msg
