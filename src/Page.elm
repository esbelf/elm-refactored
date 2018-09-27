module Page exposing (..)

import Pages.Login as Login
import Pages.Users as Users
import Pages.Groups as Groups
import Pages.Group as Group

type Page
    = Blank
    | Home
    | Groups Groups.Model
    | Group Group.Model
    | Login Login.Model
    | Users Users.Model

