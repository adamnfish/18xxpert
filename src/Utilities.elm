module Utilities exposing (..)

import Array exposing (Array)


updateArrayAt : Int -> (a -> a) -> Array a -> Array a
updateArrayAt i f aa =
    case Array.get i aa of
        Just a ->
            Array.set i (f a) aa

        Nothing ->
            aa


arrayRemoveAt : Int -> Array a -> Array a
arrayRemoveAt index array =
    if index < 0 then
        array

    else
        let
            len =
                Array.length array
        in
        if index >= len then
            array

        else
            let
                left =
                    Array.slice 0 index array

                right =
                    Array.slice (index + 1) (Array.length array) array
            in
            Array.append left right
