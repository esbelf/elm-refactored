module Page exposing (Page(..))

import Pages.Batches as Batches
import Pages.Group as Group
import Pages.Groups as Groups
import Pages.Login as Login
import Pages.Users as Users


type Page
    = Blank
    | Error String
    | Home
    | Groups Groups.Model
    | Group Group.Model
    | Batches Batches.Model
    | Login Login.Model
    | Users Users.Model
