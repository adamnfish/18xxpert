port module Ports exposing (..)

import Json.Encode


port persistGame : Json.Encode.Value -> Cmd msg


port requestPersistedGame : () -> Cmd msg


port receivePersistedGame : (Json.Encode.Value -> msg) -> Sub msg
