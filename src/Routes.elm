module Routes exposing (..)

type Route
  = NotFound
  | Home
  | Groups
  | Group Int
  | Batches
  | Login
  | Logout
  | Users