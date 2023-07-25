module Views.Routes exposing (..)

import Array
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events
import Element.Font as Font
import Element.Input as Input
import FontAwesome exposing (Icon, WithoutId)
import FontAwesome.Attributes
import FontAwesome.Regular
import FontAwesome.Solid
import FontAwesome.Styles
import List.Extra
import Model exposing (..)
import Utilities exposing (routesTotal, zeroes)
import Views.Shared exposing (navRow)


routesUi : Game -> RoutesData -> Ui
routesUi game routesData =
    let
        companyColor =
            Array.toList game.companies
                |> List.Extra.find (\c -> c.id == routesData.companyId)
                |> Maybe.map .colour
                |> Maybe.withDefault (rgb255 60 200 60)
    in
    { title = "Routes | 18xxpert"
    , body =
        column
            [ width fill
            , Font.size 30
            ]
            [ navRow "companies" (rgb255 200 200 60) FontAwesome.Solid.building
            , column
                [ width fill
                ]
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
                                        |> FontAwesome.withId "company-add-new-"
                                        |> FontAwesome.titled "Add new company"
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
                    , paddingEach { zeroes | top = 4 }
                    , Background.color <| rgb255 60 60 60
                    ]
                    (Array.toList <| Array.map (companySelector game routesData.companyId) game.companies)
                ]
            , navRow "routes" companyColor FontAwesome.Solid.trainSubway
            , column
                [ width fill
                ]
                (Array.indexedMap (routeUi routesData.focus) routesData.routes |> Array.toList)
            , case routesData.focus of
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
                                            |> FontAwesome.withId "route-add-new-"
                                            |> FontAwesome.titled "Add new route"
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
                                    text "Add route"
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
                                            |> FontAwesome.withId "route-add-new-"
                                            |> FontAwesome.titled "Add new route"
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
                                    text "Add route"
                                ]
                        }

                FocusedNew ->
                    row
                        [ width fill
                        , height <| px 60
                        , padding 10
                        , Background.color <| rgb255 60 200 60
                        ]
                        [ el
                            [ width <| px 40 ]
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
                        , el [] <|
                            html <|
                                (FontAwesome.Solid.dollarSign
                                    |> FontAwesome.withId "route-dollar-sign-new"
                                    |> FontAwesome.titled "Dollars"
                                    |> FontAwesome.styled
                                        [ FontAwesome.Attributes.xs
                                        , FontAwesome.Attributes.fw
                                        ]
                                    |> FontAwesome.view
                                )
                        ]

            -- result
            , navRow "payouts" (rgb255 180 120 0) FontAwesome.Solid.moneyBillTransfer
            , row
                [ width fill
                ]
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
            -- todo: consider focus
            , el
                [ width fill
                , height <| px 259
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
        , paddingEach { zeroes | right = 5 }
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
                                |> FontAwesome.titled "Dollars"
                                |> FontAwesome.styled
                                    [ FontAwesome.Attributes.xs
                                    , FontAwesome.Attributes.fw
                                    ]
                                |> FontAwesome.view
                            )
                    , el [] <|
                        text <|
                            String.fromInt amount
                    ]
            }
        , Input.button
            [ width <| px 40
            , height <| px 40
            , if focused then
                Background.color <| rgb255 160 160 160

              else
                Background.color <| rgb255 200 160 160
            , Font.center
            , Border.rounded 20
            ]
            { onPress = Just <| RoutesMsg <| DeleteRoute index
            , label =
                el [ centerX ] <|
                    html <|
                        (FontAwesome.Solid.trashCan
                            |> FontAwesome.withId ("route-delete-" ++ String.fromInt index)
                            |> FontAwesome.titled "Delete route"
                            |> FontAwesome.styled
                                [ FontAwesome.Attributes.xs
                                , FontAwesome.Attributes.fw
                                ]
                            |> FontAwesome.view
                        )
            }
        ]


numpad : Focus -> Element Msg
numpad focus =
    let
        buttonAttrs =
            [ width fill
            , height <| px 60
            , Background.color <| rgb255 200 200 200
            ]
    in
    if focus == Unfocused then
        Element.none

    else
        column
            [ width fill
            , alignBottom
            , spacing 5
            , Border.widthEach { zeroes | top = 4 }
            , Border.color <| rgb255 60 60 60
            , Background.color <| rgb255 60 60 60
            , Font.size 30
            ]
            [ row
                [ width fill
                , spacing 5
                ]
                [ Input.button
                    buttonAttrs
                    { onPress = Just <| RoutesMsg <| NumpadEntry 1
                    , label = numpadKey 1 FontAwesome.Solid.fa1
                    }
                , Input.button
                    buttonAttrs
                    { onPress = Just <| RoutesMsg <| NumpadEntry 2
                    , label = numpadKey 2 FontAwesome.Solid.fa2
                    }
                , Input.button
                    buttonAttrs
                    { onPress = Just <| RoutesMsg <| NumpadEntry 3
                    , label = numpadKey 3 FontAwesome.Solid.fa3
                    }
                ]
            , row
                [ width fill
                , spacing 5
                ]
                [ Input.button
                    buttonAttrs
                    { onPress = Just <| RoutesMsg <| NumpadEntry 4
                    , label = numpadKey 4 FontAwesome.Solid.fa4
                    }
                , Input.button
                    buttonAttrs
                    { onPress = Just <| RoutesMsg <| NumpadEntry 5
                    , label = numpadKey 5 FontAwesome.Solid.fa5
                    }
                , Input.button
                    buttonAttrs
                    { onPress = Just <| RoutesMsg <| NumpadEntry 6
                    , label = numpadKey 6 FontAwesome.Solid.fa6
                    }
                ]
            , row
                [ width fill
                , spacing 5
                ]
                [ Input.button
                    buttonAttrs
                    { onPress = Just <| RoutesMsg <| NumpadEntry 7
                    , label = numpadKey 7 FontAwesome.Solid.fa7
                    }
                , Input.button
                    buttonAttrs
                    { onPress = Just <| RoutesMsg <| NumpadEntry 8
                    , label = numpadKey 8 FontAwesome.Solid.fa8
                    }
                , Input.button
                    buttonAttrs
                    { onPress = Just <| RoutesMsg <| NumpadEntry 9
                    , label = numpadKey 9 FontAwesome.Solid.fa9
                    }
                ]
            , row
                [ width fill
                , spacing 5
                ]
                [ Input.button
                    buttonAttrs
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
                    buttonAttrs
                    { onPress = Just <| RoutesMsg <| NumpadEntry 0
                    , label = numpadKey 0 FontAwesome.Solid.fa0
                    }
                , Input.button
                    buttonAttrs
                    { onPress = Just <| RoutesMsg CloseNumpad
                    , label =
                        el
                            [ centerX
                            ]
                        <|
                            html <|
                                (FontAwesome.Solid.caretDown
                                    |> FontAwesome.withId "numpad-close"
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
companySelector game (CompanyId companyId) company =
    let
        selected =
            CompanyId companyId == company.id

        runningFor =
            Array.toList game.companies
                |> List.Extra.find (\c -> c.id == company.id)
                |> Maybe.map .routes
                |> Maybe.map (\a -> Array.foldl (+) 0 a)
    in
    if selected then
        el
            [ height <| px 40
            , width <| px 65
            , Background.color company.colour
            , Font.size 18
            ]
        --Element.none
        <|
            el
                [ centerX, centerY ]
            <|
                html <|
                    (FontAwesome.Solid.chevronDown
                        |> FontAwesome.withId ("company-nav-" ++ String.fromInt companyId)
                        |> FontAwesome.titled ("company " ++ String.fromInt companyId)
                        |> FontAwesome.styled
                            [ FontAwesome.Attributes.xs
                            , FontAwesome.Attributes.fw
                            ]
                        |> FontAwesome.view
                    )

    else
        Input.button
            [ height <| px 40
            , width <| px 65
            , Background.color company.colour
            , Font.size 18
            ]
            { onPress = Just <| NavMsg <| SelectCompany company.id
            , label =
                case runningFor of
                    Nothing ->
                        Element.none

                    Just runAmount ->
                        el
                            [ centerX ]
                        <|
                            text <|
                                String.fromInt runAmount
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
