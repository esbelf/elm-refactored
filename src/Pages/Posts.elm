module Pages.Posts exposing (..)

import Http
import Task exposing (Task)
import RemoteData exposing (WebData)

import Models.Post exposing (Post)
import Request

type Msg
  = Init
  | FetchPosts (Result Http.Error (List Post))
  | SetPostTitle String
  | SetPostDescription String
  | AddPost


type alias Model =
  { posts : WebData (List Post)
  , newPostTitle : String
  , newPostDescription : String
  , errorMsg : String
  }

init : Model
init =
    { posts = []
    , newPostTitle = ""
    , newPostDescription = ""
    , errorMsg = ""
    }

httpCommand : Msg
httpCommand =
  Request.getPosts
    |> Task.attempt FetchPosts

update : Msg -> Model -> ( Model, Msg )
update msg model =
  case msg of
    SendHttpRequest ->
      (model, httpCommand)
    FetchPosts (Err msg) ->
      ({ model | errorMsg = Just "Failed to fetch posts" }, Nothing)
    FetchPosts (Oky posts) ->
      ({ model | posts = posts }, Nothing)
    SetPostTitle title ->
      ({ model | newPostTitle = title }, Nothing)
    SetPostDescription description ->
      ({ model | newPostDescription = description }, Nothing)
    AddPost ->
      let
        newPost =
          { id = 1
          , title = model.newPostTitle
          , description = model.newPostDescription
          }
      in
        ({ model | posts = model.posts }, Nothing)
