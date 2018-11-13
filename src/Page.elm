module Page exposing (Page(..))

import Pages.Batches as Batches
import Pages.CreateBatch as CreateBatch
import Pages.CreateGroup as CreateGroup
import Pages.EditGroup as EditGroup
import Pages.Groups as Groups
import Pages.Login as Login
import Pages.Users as Users


type Page
    = Blank
    | Error String
    | Home
    | Groups Groups.Model
    | EditGroup EditGroup.Model
    | CreateGroup CreateGroup.Model
    | Batches Batches.Model
    | CreateBatch CreateBatch.Model
    | Login Login.Model
    | Users Users.Model
