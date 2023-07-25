module Main exposing (..)

import Array exposing (Array)
import Browser
import Model exposing (..)
import Update exposing (update)
import Views.View exposing (view)



-- MAIN


main : Program Flags Model Msg
main =
    Browser.document
        { view = view
        , init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { lifecycle = Welcome
      , assets = flags.assets

      -- TODO: persist companies and reload them at start time
      , game = { companies = Array.empty }
      }
    , Cmd.none
    )
