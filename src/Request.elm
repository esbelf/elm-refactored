module Request exposing (..)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
-- import RemoteData exposing (WebData)
import HttpBuilder exposing (RequestBuilder, withBody, withExpect, withQueryParams)
import Task exposing (Task)

import Models.Post exposing (Post)
-- import Pages.Posts


getPosts : Task
getPosts =
  postsDecoder
    |> Http.get postsUrl
    |> Http.toTask

  -- Http.Request (List Post)
  --let
  --  request =
  --    Http.get postsUrl postsDecoder
  --in
  --  Http.send FetchPosts request

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

