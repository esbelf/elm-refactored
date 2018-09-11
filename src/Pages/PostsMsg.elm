module Pages.PostsMsg exposing(Post, Msg)

import RemoteData exposing (WebData)

type alias Post =
  { id : Int
  , title : String
  , description : String
  }

type Msg
  = FetchPosts (WebData (List Post))
  | SetPostTitle String
  | SetPostDescription String
  | AddPost
