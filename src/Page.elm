module Page exposing (..)

import Pages.Posts as Posts
import Pages.Login as Login
import Pages.Users as Users
import Pages.Groups as Groups

type Page
    = Blank
    | Home
    | Groups Groups.Model
    | Posts Posts.Model
    | Login Login.Model
    | Users Users.Model

