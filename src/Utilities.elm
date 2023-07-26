module Utilities exposing (arrayRemoveAt, arrayUpdateAt, darken, dim, glow, lighten, routesTotal, setFocus, setRoutes, zeroes)

import Array exposing (Array)
import Element exposing (Color)
import Model exposing (Company, Focus, RoutesData)


routesTotal : RoutesData -> Int
routesTotal routesData =
    routesData.company.routes
        |> Array.foldl (+) 0


zeroes : { top : number, left : number, bottom : number, right : number }
zeroes =
    { top = 0, left = 0, bottom = 0, right = 0 }


arrayUpdateAt : Int -> (a -> a) -> Array a -> Array a
arrayUpdateAt index f array =
    let
        current =
            Array.get index array
    in
    case current of
        Nothing ->
            array

        Just value ->
            let
                updated =
                    f value
            in
            Array.set index updated array


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


setRoutes : Array Int -> RoutesData -> RoutesData
setRoutes routes data =
    let
        company =
            data.company
    in
    { data | company = { company | routes = routes } }


setFocus : Focus -> RoutesData -> RoutesData
setFocus focus data =
    { data | focus = focus }


clamp : Float -> Float
clamp f =
    Basics.max 0 <| Basics.min 1 f


dim : Element.Color -> Element.Color
dim =
    darken 0.4


glow : Element.Color -> Element.Color
glow =
    lighten 0.4


darken : Float -> Element.Color -> Element.Color
darken darkenFactor colour =
    let
        rgba =
            Element.toRgb colour
    in
    Element.fromRgb
        { red = clamp <| rgba.red * (1 - darkenFactor)
        , green = clamp <| rgba.green * (1 - darkenFactor)
        , blue = clamp <| rgba.blue * (1 - darkenFactor)
        , alpha = rgba.alpha
        }


lighten : Float -> Element.Color -> Element.Color
lighten lightenFactor colour =
    let
        rgba =
            Element.toRgb colour
    in
    Element.fromRgb
        { red = clamp <| ((1 - rgba.red) * lightenFactor) + rgba.red
        , green = clamp <| ((1 - rgba.green) * lightenFactor) + rgba.green
        , blue = clamp <| ((1 - rgba.blue) * lightenFactor) + rgba.blue
        , alpha = rgba.alpha
        }
