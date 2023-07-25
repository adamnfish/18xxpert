module Views.Companies exposing (..)

import Array
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import FontAwesome
import FontAwesome.Attributes
import FontAwesome.Regular
import FontAwesome.Solid
import List.Extra
import Model exposing (Company, CompanyId(..), CompanyMsg(..), Game, Msg(..), NavMsg(..), Ui)
import Utilities exposing (dim, glow, zeroes)
import Views.Shared exposing (navRow)


companyUi : Game -> Ui
companyUi game =
    { title = "New company | 18xxpert"
    , body =
        column
            [ width fill ]
            [ navRow "companies" (rgb255 200 200 60) FontAwesome.Solid.building
            , el [ centerX ] <|
                wrappedRow
                    [ centerX
                    , padding 20
                    , spacing 10
                    ]
                    (List.map (colourPicker game) colours)
            ]
    , modal = Nothing
    }


colourPicker : Game -> CompanyColour -> Element Msg
colourPicker game companyColor =
    let
        alreadyRunning =
            List.Extra.find
                (\c -> c.colour == companyColor.colour)
                (Array.toList game.companies)
                |> Maybe.map (\c -> ( Array.foldl (+) 0 c.routes, c.id ))
    in
    case alreadyRunning of
        Just ( runAmount, CompanyId id ) ->
            row
                [ width <| px 100
                , height <| px 44
                , Background.color companyColor.colour
                , Border.width 2
                , Border.color <| rgb255 60 60 60
                , Border.rounded 4
                ]
                [ Input.button
                    [ width fill
                    , height fill
                    , mouseOver
                        [ Background.color <| dim companyColor.colour
                        , Border.color <| rgb255 180 180 180
                        ]
                    , mouseDown
                        [ Background.color <| glow companyColor.colour
                        , Border.color <| rgb255 120 120 120
                        ]
                    , Font.color <| brightnessColour companyColor.textBrightness
                    ]
                    { onPress =
                        Just <| NavMsg <| SelectCompany (CompanyId id)
                    , label =
                        el
                            [ width fill ]
                        <|
                            text <|
                                String.fromInt runAmount
                    }
                , Input.button
                    [ width <| px 30
                    , paddingEach { zeroes | right = 2 }
                    , height fill
                    , Font.center
                    , Background.color
                        (case companyColor.textBrightness of
                            Dark ->
                                dim companyColor.colour

                            Light ->
                                glow companyColor.colour
                        )
                    , Border.roundEach { topLeft = 0, topRight = 4, bottomLeft = 0, bottomRight = 4 }
                    , Border.widthEach { zeroes | left = 2 }
                    , Border.color <| rgb255 0 0 0
                    , mouseOver
                        [ Background.color
                            (case companyColor.textBrightness of
                                Dark ->
                                    dim companyColor.colour

                                Light ->
                                    glow companyColor.colour
                            )
                        , Border.color <| rgba255 0 0 0 0.5
                        ]
                    , mouseDown
                        [ Background.color
                            (case companyColor.textBrightness of
                                Dark ->
                                    dim companyColor.colour

                                Light ->
                                    glow companyColor.colour
                            )
                        , Border.color <| rgb255 120 120 120
                        ]
                    , Font.color <| brightnessColour companyColor.textBrightness
                    ]
                    { onPress =
                        Just <| CompanyMsg <| DeleteCompany (CompanyId id)
                    , label =
                        el
                            [ centerX
                            , paddingXY 0 0
                            ]
                        <|
                            html <|
                                (FontAwesome.Regular.trashCan
                                    |> FontAwesome.withId ("company-delete-company-" ++ String.fromInt id)
                                    |> FontAwesome.titled "Delete company"
                                    |> FontAwesome.styled
                                        [ FontAwesome.Attributes.xs
                                        , FontAwesome.Attributes.fw
                                        ]
                                    |> FontAwesome.view
                                )
                    }
                ]

        Nothing ->
            Input.button
                [ width <| px 100
                , height <| px 44
                , Region.description companyColor.name
                , Background.color companyColor.colour
                , Border.width 2
                , Border.color <| rgb255 60 60 60
                , Border.rounded 4
                , mouseOver
                    [ Background.color <| dim companyColor.colour
                    , Border.color <| rgb255 180 180 180
                    ]
                , mouseDown
                    [ Background.color <| glow companyColor.colour
                    , Border.color <| rgb255 120 120 120
                    ]
                , Font.color <| brightnessColour companyColor.textBrightness
                ]
                { onPress =
                    Just <| CompanyMsg <| AddCompany companyColor.colour
                , label =
                    el
                        [ width <| px 30
                        , alignRight
                        ]
                    <|
                        html <|
                            (FontAwesome.Regular.squarePlus
                                |> FontAwesome.withId ("company-delete-company-" ++ colourId companyColor.colour)
                                |> FontAwesome.titled ("Start " ++ companyColor.name ++ " company")
                                |> FontAwesome.styled
                                    [ FontAwesome.Attributes.xs
                                    , FontAwesome.Attributes.fw
                                    ]
                                |> FontAwesome.view
                            )
                }


type TextBrightness
    = Dark
    | Light


brightnessColour : TextBrightness -> Color
brightnessColour textBrightness =
    case textBrightness of
        Dark ->
            rgba255 0 0 0 0.8

        Light ->
            rgba255 255 255 255 0.8


type alias CompanyColour =
    { colour : Color
    , name : String
    , textBrightness : TextBrightness
    }


colours : List CompanyColour
colours =
    [ { colour = rgb255 180 180 180
      , name = "grey"
      , textBrightness = Dark
      }
    , { colour = rgb255 100 100 100
      , name = "dark grey"
      , textBrightness = Light
      }
    , { colour = rgb255 0 0 0
      , name = "black"
      , textBrightness = Light
      }
    , { colour = rgb255 10 210 230
      , name = "cyan"
      , textBrightness = Dark
      }
    , { colour = rgb255 0 128 128
      , name = "teal"
      , textBrightness = Light
      }
    , { colour = rgb255 10 90 180
      , name = "navy"
      , textBrightness = Light
      }
    , { colour = rgb255 0 50 0
      , name = "dark green"
      , textBrightness = Light
      }
    , { colour = rgb255 0 128 0
      , name = "green"
      , textBrightness = Light
      }
    , { colour = rgb255 80 230 50
      , name = "lime"
      , textBrightness = Dark
      }
    , { colour = rgb255 230 220 20
      , name = "yellow"
      , textBrightness = Dark
      }
    , { colour = rgb255 255 165 0
      , name = "orange"
      , textBrightness = Dark
      }
    , { colour = rgb255 150 75 0
      , name = "brown"
      , textBrightness = Light
      }
    , { colour = rgb255 128 0 0
      , name = "maroon"
      , textBrightness = Light
      }
    , { colour = rgb255 210 20 20
      , name = "red"
      , textBrightness = Light
      }
    , { colour = rgb255 128 0 128
      , name = "purple"
      , textBrightness = Light
      }
    , { colour = rgb255 255 0 255
      , name = "magenta"
      , textBrightness = Dark
      }
    , { colour = rgb255 255 192 203
      , name = "salmon"
      , textBrightness = Dark
      }
    ]


companySelector : Company -> Element Msg
companySelector company =
    Input.button
        [ height <| px 20
        , width <| px 30
        , Background.color company.colour
        ]
        { onPress = Just <| NavMsg <| SelectCompany company.id
        , label = Element.none
        }


colourId : Color -> String
colourId color =
    Element.toRgb color
        |> (\{ red, green, blue } ->
                String.fromFloat red ++ "-" ++ String.fromFloat green ++ "-" ++ String.fromFloat blue
           )
        |> (\s -> "company-colour-" ++ s)
