module Msg exposing (..)

import Pages.Posts
import Pages.Login

type Msg
  = PostsMsg Pages.Posts.Msg
  | LoginMsg Pages.Login.Msg

