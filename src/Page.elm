module Page exposing (..)

import Pages.Posts as Posts
import Pages.Login as Login

type Page
    = Blank
    | Posts Posts.Model
    | Login Login.Model

initialPage : Page
initialPage =
    Posts Posts.init
