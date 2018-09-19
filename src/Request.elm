module Request exposing (..)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Task exposing (Task)

import Models.Post exposing (Post)

fetchPosts : Task Http.Error (List Post)
fetchPosts =
  Http.get postsUrl postsDecoder
    |> Http.toTask

url : String
url =
  "http://localhost:4000"

postsUrl : String
postsUrl =
  url ++ "/posts"

postsDecoder : Decode.Decoder (List Post)
postsDecoder =
  Decode.list postDecoder

postDecoder : Decode.Decoder Post
postDecoder =
  decode Post
    |> required "id" Decode.int
    |> required "title" Decode.string
    |> required "description" Decode.string

