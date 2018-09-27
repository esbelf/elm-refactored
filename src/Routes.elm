module Routes exposing (..)

type Route
  = NotFound
  | Home
  | Groups
  | Group Int
  | Login
  | Users