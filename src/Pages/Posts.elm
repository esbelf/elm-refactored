module Pages.Posts exposing (..)

import Http
import Task exposing (Task)

import Models.Post exposing (Post)
import Requests.Post as Request

type Msg
  = SetPostTitle String
  | SetPostDescription String
  | AddPost
  | PostCreate (Result Http.Error Post)

type alias Model =
  { posts : List Post
  , newPostTitle : String
  , newPostDescription : String
  , errorMsg : String
  }

initialModel : Model
initialModel =
    { posts = []
    , newPostTitle = ""
    , newPostDescription = ""
    , errorMsg = ""
    }


init : String -> Task Http.Error Model
init token =
  Task.map addPostsToModel (Request.fetchPosts token)

addPostsToModel : (List Post) -> Model
addPostsToModel posts =
  { initialModel | posts = posts }

update : Msg -> Model -> String -> ( Model, Cmd Msg )
update msg model session =
  case msg of
    SetPostTitle title ->
      ({ model | newPostTitle = title }, Cmd.none)
    SetPostDescription description ->
      ({ model | newPostDescription = description }, Cmd.none)
    AddPost ->
      let
        newPost =
          { title = model.newPostTitle
          , description = model.newPostDescription
          }
        newMsg = Request.createPost newPost session
          |> Task.attempt PostCreate
      in
        (model, newMsg)
    PostCreate (Ok newPost) ->
      ({ model | posts = model.posts ++ [newPost] }, Cmd.none)
    PostCreate (Err error) ->
      (model, Cmd.none)


