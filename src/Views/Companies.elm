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
import Model exposing (Company, CompanyColour, CompanyId(..), CompanyMsg(..), Game, Msg(..), NavMsg(..), TextBrightness(..), Ui, WindowDimensions)
import Utilities exposing (dim, glow, zeroes)
import Views.Shared exposing (container, navRow, textColourForCompany)


companyUi : WindowDimensions -> Game -> Ui
companyUi window game =
    { title = "New company | 18xxpert"
    , body =
        column
            [ width fill ]
            [ navRow "companies" (rgb255 60 60 60) (rgba255 255 255 255 0.8) FontAwesome.Solid.building
            , el
                (container [ paddingEach { top = 10, bottom = 10, left = 10, right = 0 } ])
              <|
                el
                    [ centerX ]
                <|
                    wrappedRow
                        [ spacing 10
                        ]
                        (List.map (colourPicker window game) colours)
            ]
    , modal = Nothing
    }


colourPicker : WindowDimensions -> Game -> CompanyColour -> Element Msg
colourPicker window game companyColor =
    let
        alreadyRunning =
            List.Extra.find
                (\c -> c.colourInfo.name == companyColor.name)
                (Array.toList game.companies)
                |> Maybe.map (\c -> ( Array.foldl (+) 0 c.routes, c.id ))

        pillWidth =
            if window.width < 260 then
                window.width - 20

            else if window.width < 375 then
                ((window.width - 21) // 2) - 4

            else if window.width < 520 then
                ((window.width - 21) // 3) - 6

            else if window.width < 700 then
                ((window.width - 21) // 4) - 7

            else
                130
    in
    case alreadyRunning of
        Just ( runAmount, CompanyId id ) ->
            row
                [ width <| px pillWidth
                , height <| px 44
                ]
                [ Input.button
                    [ width fill
                    , height fill
                    , Border.widthEach { left = 2, top = 2, bottom = 2, right = 0 }
                    , Border.roundEach { topLeft = 4, topRight = 0, bottomLeft = 4, bottomRight = 0 }
                    , Border.color <| rgb255 60 60 60
                    , Background.color companyColor.colour
                    , mouseOver
                        [ Background.color <| dim companyColor.colour
                        ]
                    , mouseDown
                        [ Background.color <| glow companyColor.colour
                        ]
                    ]
                    { onPress =
                        Just <| NavMsg <| SelectCompany (CompanyId id)
                    , label =
                        row
                            [ alignRight
                            , paddingEach { zeroes | right = 6 }
                            , Font.color <| textColourForCompany companyColor
                            ]
                            [ el
                                []
                              <|
                                html <|
                                    (FontAwesome.Solid.dollarSign
                                        |> FontAwesome.withId ("company-select-dollar-" ++ String.fromInt id)
                                        |> FontAwesome.titled "$"
                                        |> FontAwesome.styled
                                            [ FontAwesome.Attributes.xs
                                            , FontAwesome.Attributes.fw
                                            ]
                                        |> FontAwesome.view
                                    )
                            , text <|
                                String.fromInt runAmount
                            ]
                    }
                , Input.button
                    [ width <| px 40
                    , paddingEach { zeroes | right = 2 }
                    , height fill
                    , Font.center
                    , Background.color <| rgb255 40 10 10
                    , Border.roundEach { topLeft = 0, topRight = 4, bottomLeft = 0, bottomRight = 4 }
                    , Border.widthEach { left = 2, top = 2, bottom = 2, right = 2 }
                    , Border.color <| rgb255 60 60 60
                    , mouseOver
                        [ Background.color <| rgb255 100 10 10
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
                    ]
                    { onPress =
                        Just <| CompanyMsg <| DeleteCompany (CompanyId id)
                    , label =
                        el
                            [ centerX
                            , paddingXY 0 0
                            , Font.color <| rgba255 255 255 255 0.8
                            ]
                        <|
                            html <|
                                (FontAwesome.Regular.trashCan
                                    |> FontAwesome.withId ("company-delete-company-" ++ String.fromInt id)
                                    |> FontAwesome.titled ("Delete " ++ companyColor.name ++ " company")
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
                [ width <| px pillWidth
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
                , Font.color <| textColourForCompany companyColor
                ]
                { onPress =
                    Just <| CompanyMsg <| AddCompany companyColor
                , label =
                    el
                        [ paddingXY 10 0
                        , alignRight
                        ]
                    <|
                        html <|
                            (FontAwesome.Regular.squarePlus
                                |> FontAwesome.withId ("company-add-company-" ++ colourId companyColor.colour)
                                |> FontAwesome.titled ("Start " ++ companyColor.name ++ " company")
                                |> FontAwesome.styled
                                    [ FontAwesome.Attributes.xs
                                    , FontAwesome.Attributes.fw
                                    ]
                                |> FontAwesome.view
                            )
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


colourId : Color -> String
colourId color =
    Element.toRgb color
        |> (\{ red, green, blue } ->
                String.fromFloat red ++ "-" ++ String.fromFloat green ++ "-" ++ String.fromFloat blue
           )
        |> (\s -> "company-colour-" ++ s)
