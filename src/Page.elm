module Page exposing (..)

import Pages.Posts as Posts
import Pages.Login as Login

type Page
    = Blank
    | Home
    | Posts Posts.Model
    | Login Login.Model

