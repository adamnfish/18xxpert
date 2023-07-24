module Main exposing (..)

import Array exposing (Array)
import Browser
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
import Utilities exposing (arrayRemoveAt, updateArrayAt)



-- MAIN


main : Program () Model Msg
main =
    Browser.document
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = \_ -> Sub.none
        }



-- MODEL


type alias Model =
    { lifecycle : Lifecycle
    }


type Lifecycle
    = Welcome
    | Routes RoutesData
    | Payouts


type alias RoutesData =
    { routes : Array Int
    , focus : Focus
    }


type Focus
    = Focused Int
    | FocusedNew
    | Unfocused


init : ( Model, Cmd Msg )
init =
    ( { lifecycle = Routes { routes = Array.empty, focus = FocusedNew }
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = NoOp
    | RoutesMsg RoutesMsg


type RoutesMsg
    = NumpadEntry Int
    | NumpadBackspace
    | FocusRoute Int
    | FocusOnNewRoute
    | DeleteRoute Int
    | CloseNumpad


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        RoutesMsg routesMsg ->
            case model.lifecycle of
                Welcome ->
                    -- error
                    ( model, Cmd.none )

                Payouts ->
                    -- error
                    ( model, Cmd.none )

                Routes data ->
                    case routesMsg of
                        NumpadEntry n ->
                            case data.focus of
                                Unfocused ->
                                    -- error
                                    ( model, Cmd.none )

                                FocusedNew ->
                                    -- add new route, focus it, and add this amount to it
                                    let
                                        newRoutes =
                                            Array.push n data.routes
                                    in
                                    ( { model
                                        | lifecycle =
                                            Routes
                                                { data
                                                    | routes = newRoutes
                                                    , focus = Focused <| Array.length data.routes
                                                }
                                      }
                                    , Cmd.none
                                    )

                                Focused focusIndex ->
                                    case Array.get focusIndex data.routes of
                                        Just currentAmount ->
                                            let
                                                newAmount =
                                                    -- this limit prevents the number from overflowing
                                                    -- and ensures the integer division used for backspace works
                                                    if currentAmount > 999999999 then
                                                        currentAmount

                                                    else
                                                        currentAmount * 10 + n

                                                newRoutes =
                                                    Array.set focusIndex newAmount data.routes
                                            in
                                            ( { model | lifecycle = Routes { data | routes = newRoutes } }, Cmd.none )

                                        Nothing ->
                                            -- error
                                            ( model, Cmd.none )

                        FocusRoute focusIndex ->
                            ( { model | lifecycle = Routes { data | focus = Focused focusIndex } }
                            , Cmd.none
                            )

                        FocusOnNewRoute ->
                            ( { model | lifecycle = Routes { data | focus = FocusedNew } }
                            , Cmd.none
                            )

                        DeleteRoute index ->
                            let
                                newRoutes =
                                    arrayRemoveAt index data.routes

                                newData =
                                    { data
                                        | routes = newRoutes
                                        , focus =
                                            if data.focus == Focused index then
                                                Unfocused

                                            else
                                                data.focus
                                    }
                            in
                            ( { model | lifecycle = Routes newData }, Cmd.none )

                        NumpadBackspace ->
                            case data.focus of
                                Unfocused ->
                                    -- error
                                    ( model, Cmd.none )

                                FocusedNew ->
                                    -- NoOp
                                    ( model, Cmd.none )

                                Focused focusIndex ->
                                    case Array.get focusIndex data.routes of
                                        Just currentAmount ->
                                            let
                                                _ =
                                                    Debug.log "currentAmount" currentAmount

                                                newAmount =
                                                    currentAmount // 10

                                                _ =
                                                    Debug.log "newAmount" newAmount

                                                newData =
                                                    if newAmount == 0 then
                                                        { data
                                                            | routes = arrayRemoveAt focusIndex data.routes
                                                            , focus = Unfocused
                                                        }

                                                    else
                                                        { data
                                                            | routes = Array.set focusIndex newAmount data.routes
                                                        }
                                            in
                                            ( { model | lifecycle = Routes newData }, Cmd.none )

                                        Nothing ->
                                            -- error
                                            ( model, Cmd.none )

                        CloseNumpad ->
                            -- todo: use focus maybe properly
                            ( { model | lifecycle = Routes { data | focus = Unfocused } }
                            , Cmd.none
                            )


routesTotal : RoutesData -> Int
routesTotal routesData =
    routesData.routes
        |> Array.foldl (+) 0



-- VIEW


type alias Ui =
    { title : String
    , body : Element Msg
    , modal : Maybe (Element Msg)
    }


view : Model -> Browser.Document Msg
view model =
    let
        ui =
            renderUi model

        modal =
            Maybe.withDefault Element.none ui.modal
    in
    { title = ui.title
    , body =
        [ FontAwesome.Styles.css
        , layout
            [ width fill
            , height fill
            , inFront modal
            ]
          <|
            ui.body
        ]
    }


renderUi : Model -> Ui
renderUi model =
    let
        pageUi =
            case model.lifecycle of
                Welcome ->
                    welcomeUi

                Routes routesData ->
                    routesUi routesData

                Payouts ->
                    payoutsUi
    in
    { title = pageUi.title ++ " | 18xxpert"
    , body =
        el
            [ width fill
            , height fill
            ]
            pageUi.body
    , modal = pageUi.modal
    }


welcomeUi : Ui
welcomeUi =
    { title = "Welcome"
    , body =
        Element.text "Welcome"
    , modal = Nothing
    }


routesUi : RoutesData -> Ui
routesUi routesData =
    { title = "Routes"
    , body =
        column
            [ width fill
            , Font.size 30
            ]
            [ navRow "routes" (rgb255 200 200 60) FontAwesome.Solid.trainSubway
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
                                    , alignBottom
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
                                    , alignBottom
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
                            , alignBottom
                            , Font.color <| rgba255 220 220 220 0.8
                            ]
                          <|
                            text "Total"

                        -- TODO: show an error when it is not a multiple of 10
                        , el
                            [ width <| fillPortion 2
                            , paddingXY 6 0
                            , Font.alignRight
                            , alignBottom
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
                        [ width <| px 40 ]
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
                    , el [ height fill ] <|
                        el [ alignBottom ] <|
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


payoutsUi : Ui
payoutsUi =
    { title = "Payouts"
    , body =
        Element.text "Payouts"
    , modal = Nothing
    }


numpad : Focus -> Element Msg
numpad focus =
    let
        buttonAttrs =
            [ width fill
            , height <| px 60
            , alignBottom
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


navRow : String -> Color -> Icon WithoutId -> Element Msg
navRow title color icon =
    row
        [ width fill
        , padding 10
        , spacing 10
        , Background.color color
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
            , alignBottom
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
            , alignBottom
            ]
          <|
            text
                (if total == 0 then
                    "-"

                 else
                    String.fromInt (shareCount * total // 10)
                )
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


zeroes : { top : number, left : number, bottom : number, right : number }
zeroes =
    { top = 0, left = 0, bottom = 0, right = 0 }
