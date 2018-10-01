module Routes exposing (..)

type Route
  = NotFound
  | Home
  | Groups
  | Group Int
  | GroupPreview Int
  | Batches
  | Login
  | Logout
  | Users