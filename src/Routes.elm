module Routes exposing (..)

type Route
  = NotFound
  | Home
  | Groups
  | Group Int
  | Posts
  | Login
  | Users