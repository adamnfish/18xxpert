module Views.Routes exposing (..)

import Array
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import FontAwesome exposing (Icon, WithoutId)
import FontAwesome.Attributes
import FontAwesome.Regular
import FontAwesome.Solid
import FontAwesome.Styles
import Html.Attributes
import List.Extra
import Model exposing (..)
import Utilities exposing (routesTotal, zeroes)
import Views.Shared exposing (container, navRow, textColourForCompany)


routesUi : Game -> RoutesData -> Ui
routesUi game routesData =
    let
        companyColor =
            Array.toList game.companies
                |> List.Extra.find (\c -> c.id == routesData.company.id)
                |> Maybe.map (\c -> c.colourInfo)
                |> Maybe.withDefault
                    { colour = rgb255 230 230 230
                    , name = "unknown"
                    , textBrightness = Dark
                    }
    in
    { title = "Routes | 18xxpert"
    , body =
        column
            [ width fill
            , Font.size 30
            ]
            [ navRow "companies" (rgb255 60 60 60) (rgba255 255 255 255 0.8) FontAwesome.Solid.building
            , column
                [ width fill ]
                [ Input.button
                    [ width fill
                    , height <| px 60
                    , padding 10
                    , Background.color <| rgb255 200 200 200
                    ]
                    { onPress = Just <| NavMsg GoToCompanies
                    , label =
                        row
                            [ width fill
                            ]
                            [ el [ width <| px 40 ] <|
                                html <|
                                    (FontAwesome.Solid.briefcase
                                        |> FontAwesome.withId "company-manage-companies"
                                        |> FontAwesome.titled "Manage companies"
                                        |> FontAwesome.styled
                                            [ FontAwesome.Attributes.xs
                                            , FontAwesome.Attributes.fw
                                            ]
                                        |> FontAwesome.view
                                    )
                            , el
                                [ Font.size 18
                                , Font.color <| rgb255 80 80 80
                                ]
                              <|
                                text "Manage companies"
                            ]
                    }
                , wrappedRow
                    [ width fill
                    , spacing 4
                    , paddingEach { top = 4, left = 4, right = 4, bottom = 0 }
                    , Background.color <| rgb255 60 60 60
                    ]
                    (Array.toList <| Array.map (companySelector game routesData.company.id) game.companies)
                ]
            , navRow "routes" companyColor.colour (textColourForCompany companyColor) FontAwesome.Solid.trainSubway
            , column
                [ width fill ]
                (Array.indexedMap (routeUi routesData.focus) routesData.company.routes |> Array.toList)
            , el [ width fill ] <|
                case routesData.focus of
                    Unfocused ->
                        Input.button
                            [ width fill
                            , height <| px 60
                            , padding 10
                            , Background.color <| rgb255 200 200 200
                            ]
                            { onPress = Just <| RoutesMsg FocusOnNewRoute
                            , label =
                                row
                                    [ width fill
                                    ]
                                    [ el [ width <| px 40 ] <|
                                        html <|
                                            (FontAwesome.Regular.squarePlus
                                                |> FontAwesome.withId "route-unfocused-add-new-"
                                                |> FontAwesome.titled "Add new route"
                                                |> FontAwesome.styled
                                                    [ FontAwesome.Attributes.xs
                                                    , FontAwesome.Attributes.fw
                                                    ]
                                                |> FontAwesome.view
                                            )
                                    , el
                                        [ paddingXY 7 0
                                        , Font.size 18
                                        , Font.color <| rgb255 80 80 80
                                        ]
                                      <|
                                        text "add route"
                                    ]
                            }

                    Focused focusIndex ->
                        Input.button
                            [ width fill
                            , height <| px 60
                            , padding 10
                            , Background.color <| rgb255 200 200 200
                            ]
                            { onPress = Just <| RoutesMsg FocusOnNewRoute
                            , label =
                                row
                                    [ width fill
                                    ]
                                    [ el [ width <| px 40 ] <|
                                        html <|
                                            (FontAwesome.Regular.squarePlus
                                                |> FontAwesome.withId "route-focused-add-new-"
                                                |> FontAwesome.titled "Add new route"
                                                |> FontAwesome.styled
                                                    [ FontAwesome.Attributes.xs
                                                    , FontAwesome.Attributes.fw
                                                    ]
                                                |> FontAwesome.view
                                            )
                                    , el
                                        [ paddingXY 7 0
                                        , Font.size 18
                                        , Font.color <| rgb255 80 80 80
                                        ]
                                      <|
                                        text "add route"
                                    ]
                            }

                    FocusedNew ->
                        row
                            [ width fill
                            , height <| px 60
                            , Background.color <| rgb255 60 200 60
                            ]
                            [ el
                                [ width <| px 40
                                , padding 10
                                ]
                              <|
                                html <|
                                    (FontAwesome.Solid.chevronRight
                                        |> FontAwesome.withId "route-selected-new"
                                        |> FontAwesome.titled "Selected"
                                        |> FontAwesome.styled
                                            [ FontAwesome.Attributes.xs
                                            , FontAwesome.Attributes.fw
                                            ]
                                        |> FontAwesome.view
                                    )
                            , el [ padding 10 ] <|
                                html <|
                                    (FontAwesome.Solid.dollarSign
                                        |> FontAwesome.withId "route-dollar-sign-new"
                                        |> FontAwesome.titled "$"
                                        |> FontAwesome.styled
                                            [ FontAwesome.Attributes.xs
                                            , FontAwesome.Attributes.fw
                                            ]
                                        |> FontAwesome.view
                                    )
                            , Input.button
                                [ width <| px 35
                                , height fill
                                , alignRight
                                , Background.color <| rgb255 160 160 160
                                , Font.center
                                , Border.widthEach { zeroes | left = 4, top = 1, bottom = 1 }
                                , Border.color <| rgb255 60 60 60
                                ]
                                { onPress = Just <| RoutesMsg CloseNumpad
                                , label =
                                    el
                                        [ centerX
                                        ]
                                    <|
                                        html <|
                                            (FontAwesome.Solid.cancel
                                                |> FontAwesome.withId "numpad-close-from-focused-route"
                                                |> FontAwesome.titled "Cancel"
                                                |> FontAwesome.styled
                                                    [ FontAwesome.Attributes.xs
                                                    , FontAwesome.Attributes.fw
                                                    ]
                                                |> FontAwesome.view
                                            )
                                }
                            ]

            -- result
            , navRow "payouts" companyColor.colour (textColourForCompany companyColor) FontAwesome.Solid.moneyBillTransfer
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ payoutRow 1 (routesTotal routesData)
                    , payoutRow 2 (routesTotal routesData)
                    , payoutRow 3 (routesTotal routesData)
                    , payoutRow 4 (routesTotal routesData)
                    , payoutRow 5 (routesTotal routesData)
                    ]
                , column
                    [ width fill ]
                    [ payoutRow 6 (routesTotal routesData)
                    , payoutRow 7 (routesTotal routesData)
                    , payoutRow 8 (routesTotal routesData)
                    , payoutRow 9 (routesTotal routesData)
                    , row
                        [ width fill
                        , height <| px 40
                        , spacing 18
                        , Background.color <| rgb255 60 60 60
                        , Font.color <| rgba255 255 255 255 0.8
                        ]
                        [ el
                            [ width <| fillPortion 3
                            , paddingXY 5 3
                            , Font.size 18
                            , Font.alignLeft
                            , Font.color <| rgba255 220 220 220 0.8
                            ]
                          <|
                            text "Total"

                        -- TODO: show an error when it is not a multiple of 10
                        , el
                            [ width <| fillPortion 2
                            , paddingXY 6 0
                            , Font.alignRight
                            , Font.bold
                            ]
                          <|
                            text <|
                                String.fromInt <|
                                    routesTotal routesData
                        ]
                    ]
                ]

            -- space for the numpad
            , el
                [ width fill
                , height <|
                    if routesData.focus == Unfocused then
                        px 0

                    else
                        px 256
                ]
              <|
                Element.none
            ]
    , modal = Just <| numpad routesData.focus
    }


routeUi : Focus -> Int -> Int -> Element Msg
routeUi focus index amount =
    let
        focused =
            Focused index == focus

        attrs =
            [ width fill
            , height <| px 60
            , padding 10
            ]
    in
    row
        [ width fill
        , Background.color <|
            if focused then
                rgb255 60 200 60

            else
                rgb255 200 200 200
        ]
        [ Input.button
            attrs
            { onPress = Just <| RoutesMsg <| FocusRoute index
            , label =
                row
                    [ width fill
                    , height fill
                    ]
                    [ el
                        [ width <| px 40
                        ]
                        (if focused then
                            html <|
                                (FontAwesome.Solid.chevronRight
                                    |> FontAwesome.withId ("route-selected-" ++ String.fromInt index)
                                    |> FontAwesome.titled "Selected"
                                    |> FontAwesome.styled
                                        [ FontAwesome.Attributes.xs
                                        , FontAwesome.Attributes.fw
                                        ]
                                    |> FontAwesome.view
                                )

                         else
                            html <|
                                (FontAwesome.Regular.edit
                                    |> FontAwesome.withId ("route-edit-" ++ String.fromInt index)
                                    |> FontAwesome.titled "Edit route"
                                    |> FontAwesome.styled
                                        [ FontAwesome.Attributes.xs
                                        , FontAwesome.Attributes.fw
                                        ]
                                    |> FontAwesome.view
                                )
                        )
                    , el [] <|
                        html <|
                            (FontAwesome.Solid.dollarSign
                                |> FontAwesome.withId ("route-dollar-sign-" ++ String.fromInt index)
                                |> FontAwesome.titled "$"
                                |> FontAwesome.styled
                                    [ FontAwesome.Attributes.xs
                                    , FontAwesome.Attributes.fw
                                    ]
                                |> FontAwesome.view
                            )
                    , if focused then
                        row
                            []
                            [ text <|
                                String.fromInt amount
                            , el
                                [ height fill
                                , paddingEach { zeroes | right = 2 }
                                , Border.widthEach { zeroes | right = 1 }
                                , Border.color <| rgba255 60 60 60 0.6
                                , htmlAttribute <| Html.Attributes.style "animation" "blink 1s linear infinite"
                                ]
                                Element.none
                            ]

                      else
                        el [] <|
                            text <|
                                String.fromInt amount
                    ]
            }
        , if focused then
            let
                deltaButtonAttrs =
                    [ width <| px 49
                    , padding 5
                    , Background.color <| rgb255 160 160 160
                    , Border.color <| rgb255 60 60 60
                    ]
            in
            el
                [ alignRight
                , height fill
                , paddingXY 5 0
                ]
            <|
                el
                    [ height fill
                    , width <| px 49
                    , above <|
                        Input.button
                            ([ moveDown 18
                             , Border.widthEach { bottom = 4, top = 1, left = 1, right = 1 }
                             , Region.description "add 10"
                             ]
                                ++ deltaButtonAttrs
                            )
                            { onPress = Just <| RoutesMsg <| RouteDelta 10
                            , label =
                                el
                                    [ width fill
                                    , centerX
                                    , moveRight 3
                                    ]
                                <|
                                    html <|
                                        (FontAwesome.Solid.plus
                                            |> FontAwesome.withId ("route-increment-" ++ String.fromInt index)
                                            |> FontAwesome.titled "add 10"
                                            |> FontAwesome.styled
                                                [ FontAwesome.Attributes.sm
                                                , FontAwesome.Attributes.fw
                                                ]
                                            |> FontAwesome.view
                                        )
                            }
                    , below <|
                        Input.button
                            ([ moveUp 18
                             , Border.widthEach { bottom = 1, top = 4, left = 1, right = 1 }
                             , Region.description "subtract 10"
                             ]
                                ++ deltaButtonAttrs
                            )
                            { onPress = Just <| RoutesMsg <| RouteDelta -10
                            , label =
                                el
                                    [ width fill
                                    , centerX
                                    , moveRight 3
                                    ]
                                <|
                                    html <|
                                        (FontAwesome.Solid.minus
                                            |> FontAwesome.withId ("route-decrement-" ++ String.fromInt index)
                                            |> FontAwesome.titled "subtract 10"
                                            |> FontAwesome.styled
                                                [ FontAwesome.Attributes.sm
                                                , FontAwesome.Attributes.fw
                                                ]
                                            |> FontAwesome.view
                                        )
                            }
                    ]
                <|
                    el
                        [ width <| px 32
                        , height <| px 32
                        , centerY
                        , centerX
                        , Font.size 12
                        , Font.color <| rgb255 200 200 200
                        , Background.color <| rgb255 60 60 60
                        ]
                    <|
                        el [ centerX, centerY ] <|
                            text "10"

          else
            Element.none
        , Input.button
            [ width <| px 35
            , height fill
            , if focused then
                Background.color <| rgb255 160 160 160

              else
                Background.color <| rgb255 200 160 160
            , Font.center
            , Border.widthEach { zeroes | left = 4, top = 1, bottom = 1 }
            , Border.color <| rgb255 60 60 60
            , Region.description <|
                if focused then
                    "Cancel"

                else
                    "Delete route " ++ String.fromInt (index + 1)
            ]
            { onPress =
                if focused then
                    Just <| RoutesMsg CloseNumpad

                else
                    Just <| RoutesMsg <| DeleteRoute index
            , label =
                el [ centerX ] <|
                    html <|
                        if focused then
                            FontAwesome.Solid.cancel
                                |> FontAwesome.withId ("route-close-numpad-cancel-" ++ String.fromInt index)
                                |> FontAwesome.titled "Cancel"
                                |> FontAwesome.styled
                                    [ FontAwesome.Attributes.xs
                                    , FontAwesome.Attributes.fw
                                    ]
                                |> FontAwesome.view

                        else
                            FontAwesome.Solid.trashCan
                                |> FontAwesome.withId ("route-delete-" ++ String.fromInt index)
                                |> FontAwesome.titled ("Delete route " ++ String.fromInt (index + 1))
                                |> FontAwesome.styled
                                    [ FontAwesome.Attributes.xs
                                    , FontAwesome.Attributes.fw
                                    ]
                                |> FontAwesome.view
            }
        ]


numpad : Focus -> Element Msg
numpad focus =
    let
        buttonAttrs number =
            [ width fill
            , height <| px 60
            , Background.color <| rgb255 200 200 200
            , mouseOver
                [ Background.color <| rgb255 160 160 160
                ]
            , mouseDown
                [ Background.color <| rgb255 220 220 220
                ]
            , Region.description number
            ]
    in
    if focus == Unfocused then
        Element.none

    else
        column
            [ width fill
            , alignBottom
            , spacing 4
            , Border.widthEach { zeroes | top = 4 }
            , Border.color <| rgb255 60 60 60
            , Background.color <| rgb255 60 60 60
            , Font.size 30
            ]
            [ row
                [ width fill
                , spacing 4
                ]
                [ Input.button
                    (buttonAttrs "1")
                    { onPress = Just <| RoutesMsg <| NumpadEntry 1
                    , label = numpadKey 1 FontAwesome.Solid.fa1
                    }
                , Input.button
                    (buttonAttrs "2")
                    { onPress = Just <| RoutesMsg <| NumpadEntry 2
                    , label = numpadKey 2 FontAwesome.Solid.fa2
                    }
                , Input.button
                    (buttonAttrs "3")
                    { onPress = Just <| RoutesMsg <| NumpadEntry 3
                    , label = numpadKey 3 FontAwesome.Solid.fa3
                    }
                ]
            , row
                [ width fill
                , spacing 4
                ]
                [ Input.button
                    (buttonAttrs "4")
                    { onPress = Just <| RoutesMsg <| NumpadEntry 4
                    , label = numpadKey 4 FontAwesome.Solid.fa4
                    }
                , Input.button
                    (buttonAttrs "5")
                    { onPress = Just <| RoutesMsg <| NumpadEntry 5
                    , label = numpadKey 5 FontAwesome.Solid.fa5
                    }
                , Input.button
                    (buttonAttrs "6")
                    { onPress = Just <| RoutesMsg <| NumpadEntry 6
                    , label = numpadKey 6 FontAwesome.Solid.fa6
                    }
                ]
            , row
                [ width fill
                , spacing 4
                ]
                [ Input.button
                    (buttonAttrs "7")
                    { onPress = Just <| RoutesMsg <| NumpadEntry 7
                    , label = numpadKey 7 FontAwesome.Solid.fa7
                    }
                , Input.button
                    (buttonAttrs "8")
                    { onPress = Just <| RoutesMsg <| NumpadEntry 8
                    , label = numpadKey 8 FontAwesome.Solid.fa8
                    }
                , Input.button
                    (buttonAttrs "9")
                    { onPress = Just <| RoutesMsg <| NumpadEntry 9
                    , label = numpadKey 9 FontAwesome.Solid.fa9
                    }
                ]
            , row
                [ width fill
                , spacing 4
                ]
                [ Input.button
                    (buttonAttrs "backspace")
                    { onPress = Just <| RoutesMsg <| NumpadBackspace
                    , label =
                        el
                            [ centerX
                            ]
                        <|
                            html <|
                                (FontAwesome.Solid.backspace
                                    |> FontAwesome.withId "numpad-backspace"
                                    |> FontAwesome.titled "Backspace"
                                    |> FontAwesome.styled
                                        [ FontAwesome.Attributes.xs
                                        , FontAwesome.Attributes.fw
                                        ]
                                    |> FontAwesome.view
                                )
                    }
                , Input.button
                    (buttonAttrs "0")
                    { onPress = Just <| RoutesMsg <| NumpadEntry 0
                    , label = numpadKey 0 FontAwesome.Solid.fa0
                    }
                , Input.button
                    (buttonAttrs "close numpad")
                    { onPress = Just <| RoutesMsg CloseNumpad
                    , label =
                        el
                            [ centerX
                            ]
                        <|
                            html <|
                                (FontAwesome.Solid.caretDown
                                    |> FontAwesome.withId "numpad-button-close"
                                    |> FontAwesome.titled "Close number pad"
                                    |> FontAwesome.styled
                                        [ FontAwesome.Attributes.xs
                                        , FontAwesome.Attributes.fw
                                        ]
                                    |> FontAwesome.view
                                )
                    }
                ]
            ]


numpadKey : Int -> Icon WithoutId -> Element Msg
numpadKey n icon =
    el
        [ centerX ]
    <|
        html <|
            (icon
                |> FontAwesome.withId ("numpad-" ++ String.fromInt n)
                |> FontAwesome.titled (String.fromInt n)
                |> FontAwesome.styled
                    [ FontAwesome.Attributes.xs
                    , FontAwesome.Attributes.fw
                    ]
                |> FontAwesome.view
            )


companySelector : Game -> CompanyId -> Company -> Element Msg
companySelector game (CompanyId selectedCompanyId) company =
    let
        selected =
            CompanyId selectedCompanyId == company.id

        runningFor =
            Array.toList game.companies
                |> List.Extra.find (\c -> c.id == company.id)
                |> Maybe.map .routes
                |> Maybe.map (\a -> Array.foldl (+) 0 a)
    in
    if selected then
        el
            [ height <| px 50
            , width <| px 65
            , Background.color company.colourInfo.colour
            , Font.size 18
            , Font.color <| textColourForCompany company.colourInfo
            , Border.widthEach { zeroes | bottom = 4 }
            , Border.color company.colourInfo.colour
            , Border.roundEach { topLeft = 4, topRight = 4, bottomLeft = 0, bottomRight = 0 }
            ]
        <|
            el
                [ centerX, centerY ]
            <|
                html <|
                    (FontAwesome.Solid.angleDown
                        |> FontAwesome.withId ("company-nav-selected-" ++ String.fromInt selectedCompanyId)
                        |> FontAwesome.titled ("company " ++ String.fromInt selectedCompanyId)
                        |> FontAwesome.styled
                            [ FontAwesome.Attributes.xs
                            , FontAwesome.Attributes.fw
                            ]
                        |> FontAwesome.view
                    )

    else
        el
            [ paddingEach { zeroes | bottom = 4 } ]
        <|
            Input.button
                [ height <| px 46
                , width <| px 65
                , Background.color company.colourInfo.colour
                , Font.size 18
                , Font.color <| textColourForCompany company.colourInfo
                , Border.color <| rgb255 60 60 60
                , Border.rounded 4
                , Region.description (company.colourInfo.name ++ " company")
                ]
                { onPress = Just <| NavMsg <| SelectCompany company.id
                , label =
                    case runningFor of
                        Nothing ->
                            Element.none

                        Just runAmount ->
                            row
                                [ centerX ]
                                [ el
                                    []
                                  <|
                                    html <|
                                        (FontAwesome.Solid.dollarSign
                                            |> FontAwesome.withId ("company-nav-dollar-" ++ String.fromInt selectedCompanyId)
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


payoutRow : Int -> Int -> Element Msg
payoutRow shareCount total =
    let
        striped =
            modBy 2 shareCount == 0
    in
    row
        [ width fill
        , height <| px 40
        , spacing 18
        , if striped then
            Background.color <| rgb255 200 200 200

          else
            Background.color <| rgb255 255 255 255
        ]
        [ el
            [ width fill
            , paddingXY 5 0
            , Font.size 24
            , Font.alignLeft
            , Font.color <| rgba255 100 100 100 0.8
            ]
          <|
            text <|
                if shareCount == 10 then
                    ""

                else
                    String.fromInt shareCount
                        ++ "x"
        , el
            [ width fill
            , paddingXY 6 0
            , Font.alignRight
            ]
          <|
            text
                (if total == 0 then
                    "-"

                 else
                    String.fromInt (shareCount * total // 10)
                )
        ]
