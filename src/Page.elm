module Page exposing (..)

import Pages.Posts as Posts
import Pages.Login as Login
import Pages.Users as Users

type Page
    = Blank
    | Home
    | Posts Posts.Model
    | Login Login.Model
    | Users Users.Model

