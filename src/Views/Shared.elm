module Views.Shared exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import FontAwesome exposing (Icon, WithoutId)
import FontAwesome.Attributes
import Model exposing (Msg)


navRow : String -> Color -> Icon WithoutId -> Element Msg
navRow title colour icon =
    row
        [ width fill
        , padding 10
        , spacing 10
        , Background.color colour
        , Font.size 18
        ]
        [ el
            []
          <|
            html <|
                (icon
                    |> FontAwesome.withId ("nav-item-train-" ++ title)
                    |> FontAwesome.titled title
                    |> FontAwesome.styled
                        [ FontAwesome.Attributes.xs
                        , FontAwesome.Attributes.fw
                        ]
                    |> FontAwesome.view
                )
        , el [] <| text title
        ]
