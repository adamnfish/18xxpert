module Views.Shared exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import FontAwesome exposing (Icon, WithoutId)
import FontAwesome.Attributes
import Model exposing (Company, CompanyColour, Msg, TextBrightness(..))


navRow : String -> Color -> Color -> Icon WithoutId -> Element Msg
navRow title bgColour textColour icon =
    row
        [ width fill
        , padding 10
        , spacing 10
        , Background.color bgColour
        , Font.color textColour
        , Font.size 18
        ]
        [ el
            []
          <|
            html <|
                (icon
                    |> FontAwesome.withId ("nav-item-" ++ title)
                    |> FontAwesome.titled title
                    |> FontAwesome.styled
                        [ FontAwesome.Attributes.xs
                        , FontAwesome.Attributes.fw
                        ]
                    |> FontAwesome.view
                )
        , el [] <| text title
        ]


textColourForCompany : CompanyColour -> Color
textColourForCompany companyColour =
    case companyColour.textBrightness of
        Dark ->
            rgba255 0 0 0 0.8

        Light ->
            rgba255 255 255 255 0.8


container : List (Attribute Msg) -> List (Attribute Msg)
container attrs =
    [ width <| maximum 700 fill
    , centerX
    ]
        ++ attrs
