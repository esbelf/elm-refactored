module Requests.Post exposing (..)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Task exposing (Task)

import Models.Post exposing (Post)
import Requests.Base exposing (..)


fetchPosts : Task Http.Error (List Post)
fetchPosts =
  Http.get urlPosts postsDecoder
    |> Http.toTask

postsDecoder : Decode.Decoder (List Post)
postsDecoder =
  Decode.list postDecoder

postDecoder : Decode.Decoder Post
postDecoder =
  decode Post
    |> required "id" Decode.int
    |> required "title" Decode.string
    |> required "description" Decode.string

--- Save Posts ---

type alias CreateConfig =
    { title : String
    , description : String
    }

createPost : CreateConfig -> Task Http.Error Post
createPost config =
   createRequestPost config
      |> Http.toTask

createRequestPost : CreateConfig -> Http.Request Post
createRequestPost config =
  let
    attributes =
      [ ( "title", Encode.string config.title )
      , ( "description", Encode.string config.description)
      ]
    body = Encode.object attributes
              |> Http.jsonBody
  in
    Http.request
      { body = body
      , expect = Http.expectJson postDecoder
      , headers = []
      , method = "POST"
      , timeout = Nothing
      , url = urlPosts
      , withCredentials = False
      }

updateRequestPost : Post -> Http.Request Post
updateRequestPost post =
  Http.request
    { body = encoderPost post |> Http.jsonBody
    , expect = Http.expectJson postDecoder
    , headers = []
    , method = "PUT"
    , timeout = Nothing
    , url = urlSlug post.id
    , withCredentials = False
    }

encoderPost : Post -> Encode.Value
encoderPost post =
  let
    attributes =
      [ ( "id", Encode.int post.id )
      , ( "title", Encode.string post.title )
      , ( "description", Encode.string post.description)
      ]
  in
    Encode.object attributes


urlSlug : Int -> String
urlSlug postId =
  urlPosts ++ "/" ++ (toString postId)

urlPosts : String
urlPosts =
  baseUrl ++ "/posts"
