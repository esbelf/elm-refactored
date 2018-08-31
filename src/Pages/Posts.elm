module Pages.Posts exposing (..)

type alias Post =
  { title : String
  , description : String
  }

type Msg
  = SetPostTitle String
  | SetPostDescription String
  | AddPost

type alias Model =
  { posts: List Post
  , newPostTitle : String
  , newPostDescription : String
  }

init : Model
init =
  { posts = []
  , newPostTitle = ""
  , newPostDescription = ""
  }

update : Msg -> Model -> Model
update msg model =
  case msg of
    SetPostTitle title ->
      { model | newPostTitle = title }
    SetPostDescription description ->
      { model | newPostDescription = description }
    AddPost ->
      let
        newPost =
          { title = model.newPostTitle
          , description = model.newPostDescription
          }
      in
        { model | posts = model.posts ++ [newPost] }
