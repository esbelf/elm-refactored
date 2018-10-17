module Models.Product exposing (Column, Cost, Data, Product, TimeSplit(..), init)

-- import EveryDict exposing (EveryDict)

import Dict exposing (Dict)
import Helpers.DecimalField exposing (DecimalField)


type alias Product =
    { id : Int
    , name : String

    -- , rates : List Column
    }


init : Product
init =
    { id = 0
    , name = ""

    --  , rates = []
    }



--- Sub Models for handling the json blob ---


type alias Column =
    { name : String -- EE, SP, Child or what not
    , data : List Data
    }


type alias Data =
    { display : String
    , min : Int
    , max : Int
    , received : String
    , amount : String
    , costs : Dict TimeSplit Cost
    }


type alias Cost =
    { normal : DecimalField
    , high : DecimalField
    }


type TimeSplit
    = Weekly
    | Monthly
