module Main exposing (..)

import Array exposing (Array)
import Browser
import Browser.Dom exposing (Viewport)
import Browser.Events
import Model exposing (..)
import Task
import Update exposing (update)
import Views.View exposing (view)



-- MAIN


main : Program Flags Model Msg
main =
    Browser.document
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { lifecycle = Welcome
      , assets = flags.assets

      -- TODO: persist companies and reload them at start time
      , game = { companies = Array.empty }
      , windowDimensions =
            { width = flags.viewport.width
            , height = flags.viewport.height
            }
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Browser.Events.onResize (\width height -> Resized { width = width, height = height })
        ]
