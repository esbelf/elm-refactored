module Requests.Post exposing (..)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Task exposing (Task)

import Models.Post exposing (Post)
import Requests.Base exposing (..)


fetchPosts : String -> Task Http.Error (List Post)
fetchPosts token =
  Http.request
    { body = Http.emptyBody
    , headers = []
    , expect = Http.expectJson postsDecoder
    , method = "GET"
    , timeout = Nothing
    , url = urlPosts
    , withCredentials = False
    } |> Http.toTask

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

createPost : CreateConfig -> String -> Task Http.Error Post
createPost config token =
   createRequestPost config token
      |> Http.toTask

createRequestPost : CreateConfig -> String -> Http.Request Post
createRequestPost config token  =
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
      , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
      , method = "POST"
      , timeout = Nothing
      , url = urlPosts
      , withCredentials = False
      }

updateRequestPost : Post -> String -> Http.Request Post
updateRequestPost post token =
  Http.request
    { body = encoderPost post |> Http.jsonBody
    , expect = Http.expectJson postDecoder
    , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
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
