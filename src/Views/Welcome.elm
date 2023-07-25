module Views.Welcome exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import FontAwesome exposing (Icon, WithoutId)
import FontAwesome.Attributes
import FontAwesome.Solid
import Model exposing (..)


welcomeUi : Assets -> Ui
welcomeUi assets =
    { title = "18xxpert"
    , body =
        column
            [ width fill
            , spacing 30
            ]
            [ row
                [ width fill
                , padding 10
                , spacing 10
                , Background.color <| rgb255 200 200 60
                , Font.size 18
                ]
                [ el [ centerX ] <| text "18xxpert"
                ]
            , Input.button
                [ centerX ]
                { onPress = Just Start
                , label =
                    column
                        [ width fill
                        ]
                        [ image
                            [ width <| px 200
                            ]
                            { src = assets.logo
                            , description = "18xxpert logo, a picture of a steam train with trees behind"
                            }
                        , row
                            [ centerX
                            , paddingEach { top = 15, bottom = 15, left = 20, right = 15 }
                            , Background.color <|
                                -- green
                                rgb255 40 120 40
                            , Font.color <| rgba255 255 255 255 0.8
                            , spacing 10
                            ]
                            [ el [] <| text "Start"
                            , el [] <|
                                html <|
                                    (FontAwesome.Solid.play
                                        |> FontAwesome.withId "route-add-new-"
                                        |> FontAwesome.titled "Add new route"
                                        |> FontAwesome.styled
                                            [ FontAwesome.Attributes.xs
                                            , FontAwesome.Attributes.fw
                                            ]
                                        |> FontAwesome.view
                                    )
                            ]
                        ]
                }
            , paragraph
                [ centerX
                ]
                [ text "18xx interactive player aid" ]
            ]
    , modal = Nothing
    }
