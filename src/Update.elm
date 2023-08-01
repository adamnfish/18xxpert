module Update exposing (..)

import Array
import Json.Decode
import Keyboard.Key
import Model exposing (..)
import Ports exposing (persistGame, requestPersistedGame)
import Utilities exposing (arrayRemoveAt, arrayUpdateAt, setFocus, setRoutes)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Resized dimensions ->
            ( { model
                | windowDimensions = dimensions
              }
            , Cmd.none
            )

        Start ->
            -- screen for choosing the first company
            ( { model | lifecycle = Companies }
            , Cmd.none
            )

        NavMsg navMsg ->
            case navMsg of
                GoToWelcome ->
                    ( { model | lifecycle = Welcome }
                    , Cmd.none
                    )

                GoToCompanies ->
                    let
                        newLifecycle =
                            case model.lifecycle of
                                Welcome ->
                                    Companies

                                Companies ->
                                    -- error
                                    model.lifecycle

                                Routes routesData ->
                                    Companies
                    in
                    ( { model | lifecycle = newLifecycle }
                    , Cmd.none
                    )

                SelectCompany (CompanyId companyId) ->
                    case Array.get companyId model.game.companies of
                        Just company ->
                            ( { model
                                | lifecycle =
                                    Routes
                                        { focus = Unfocused
                                        , company = company
                                        }
                              }
                            , Cmd.none
                            )

                        Nothing ->
                            -- error
                            ( model, Cmd.none )

        RoutesMsg routesMsg ->
            case model.lifecycle of
                Welcome ->
                    -- error
                    ( model, Cmd.none )

                Companies ->
                    -- error
                    ( model, Cmd.none )

                Routes data ->
                    case routesMsg of
                        NumpadEntry n ->
                            routeNumber model data n

                        FocusRoute focusIndex ->
                            focusRoute model data focusIndex

                        FocusOnNewRoute ->
                            focusNew model data

                        DeleteRoute index ->
                            let
                                newRoutes =
                                    arrayRemoveAt index data.company.routes

                                newData =
                                    data
                                        |> setRoutes newRoutes
                                        |> setFocus
                                            (if data.focus == Focused index then
                                                Unfocused

                                             else
                                                data.focus
                                            )

                                ( newGame, persistCmd ) =
                                    updateGameRoute model.game newData
                            in
                            ( { model
                                | lifecycle = Routes newData
                                , game = newGame
                              }
                            , persistCmd
                            )

                        NumpadBackspace ->
                            routeBackspace model data

                        CloseNumpad ->
                            closeNumpad model data

                        KeyboardEntry keyboardEvent ->
                            case keyboardEvent.key of
                                Just key ->
                                    case String.toInt key of
                                        Just n ->
                                            routeNumber model data n

                                        Nothing ->
                                            case keyboardEvent.keyCode of
                                                Keyboard.Key.Backspace ->
                                                    routeBackspace model data

                                                Keyboard.Key.Escape ->
                                                    closeNumpad model data

                                                Keyboard.Key.Up ->
                                                    case data.focus of
                                                        Focused 0 ->
                                                            closeNumpad model data

                                                        Focused i ->
                                                            focusRoute model data (i - 1)

                                                        FocusedNew ->
                                                            let
                                                                routeCount =
                                                                    Array.length data.company.routes
                                                            in
                                                            if routeCount > 0 then
                                                                focusRoute model data (routeCount - 1)

                                                            else
                                                                closeNumpad model data

                                                        Unfocused ->
                                                            focusNew model data

                                                Keyboard.Key.Down ->
                                                    let
                                                        routeCount =
                                                            Array.length data.company.routes
                                                    in
                                                    case data.focus of
                                                        Focused i ->
                                                            if i == routeCount - 1 then
                                                                focusNew model data

                                                            else
                                                                focusRoute model data (i + 1)

                                                        FocusedNew ->
                                                            closeNumpad model data

                                                        Unfocused ->
                                                            if routeCount > 0 then
                                                                focusRoute model data 0

                                                            else
                                                                focusNew model data

                                                Keyboard.Key.Enter ->
                                                    if data.focus == FocusedNew then
                                                        closeNumpad model data

                                                    else
                                                        focusNew model data

                                                _ ->
                                                    ( model, Cmd.none )

                                Nothing ->
                                    ( model, Cmd.none )

        CompanyMsg companyMsg ->
            case model.lifecycle of
                Welcome ->
                    -- error
                    ( model, Cmd.none )

                Routes data ->
                    -- error
                    ( model, Cmd.none )

                Companies ->
                    case companyMsg of
                        AddCompany colourInfo ->
                            let
                                game =
                                    model.game

                                newGame =
                                    { game | companies = Array.push { routes = Array.empty, colourInfo = colourInfo, id = CompanyId <| Array.length model.game.companies } model.game.companies }
                            in
                            ( { model
                                | lifecycle =
                                    Routes
                                        { focus = Unfocused
                                        , company =
                                            { id = CompanyId <| Array.length model.game.companies
                                            , colourInfo = colourInfo
                                            , routes = Array.empty
                                            }
                                        }
                                , game = newGame
                              }
                            , persistGame <| encodeGame newGame
                            )

                        DeleteCompany companyId ->
                            let
                                game =
                                    model.game

                                newGame =
                                    { game | companies = Array.filter (\company -> company.id /= companyId) model.game.companies }
                            in
                            ( { model
                                | lifecycle = Companies
                                , game = newGame
                              }
                            , persistGame <| encodeGame newGame
                            )

        UpdateGameFromStorage json ->
            case Json.Decode.decodeValue (Json.Decode.nullable gameDecoder) json of
                Ok (Just updatedGame) ->
                    -- TODO: update current lifecycle data, if needed
                    ( { model | game = updatedGame }
                    , Cmd.none
                    )

                Ok Nothing ->
                    ( model
                    , Cmd.none
                    )

                Err error ->
                    -- TODO: error
                    ( model, Cmd.none )

        RequestPersistedGame ->
            ( model
            , requestPersistedGame ()
            )


focusNew : Model -> RoutesData -> ( Model, Cmd Msg )
focusNew model data =
    ( { model | lifecycle = Routes { data | focus = FocusedNew } }
    , Cmd.none
    )


focusRoute : Model -> RoutesData -> Int -> ( Model, Cmd Msg )
focusRoute model data focusIndex =
    ( { model | lifecycle = Routes { data | focus = Focused focusIndex } }
    , Cmd.none
    )


routeNumber : Model -> RoutesData -> Int -> ( Model, Cmd Msg )
routeNumber model data n =
    case data.focus of
        Unfocused ->
            -- error
            ( model, Cmd.none )

        FocusedNew ->
            -- add new route, focus it, and add this amount to it
            let
                newRoutes =
                    Array.push n data.company.routes

                newRoutesData =
                    data
                        |> setRoutes newRoutes
                        |> setFocus (Focused <| Array.length data.company.routes)

                ( newGame, persistCmd ) =
                    updateGameRoute model.game newRoutesData
            in
            ( { model
                | lifecycle = Routes newRoutesData
                , game = newGame
              }
            , persistCmd
            )

        Focused focusIndex ->
            case Array.get focusIndex data.company.routes of
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
                            Array.set focusIndex newAmount data.company.routes

                        newRoutesData =
                            data
                                |> setRoutes newRoutes

                        ( newGame, persistCmd ) =
                            updateGameRoute model.game newRoutesData
                    in
                    ( { model
                        | lifecycle = Routes newRoutesData
                        , game = newGame
                      }
                    , persistCmd
                    )

                Nothing ->
                    -- error
                    ( model, Cmd.none )


routeBackspace : Model -> RoutesData -> ( Model, Cmd Msg )
routeBackspace model data =
    case data.focus of
        Unfocused ->
            -- error
            ( model, Cmd.none )

        FocusedNew ->
            -- NoOp
            ( { model | lifecycle = Routes { data | focus = Unfocused } }
            , Cmd.none
            )

        Focused focusIndex ->
            case Array.get focusIndex data.company.routes of
                Just currentAmount ->
                    let
                        newAmount =
                            currentAmount // 10

                        newData =
                            if newAmount == 0 then
                                let
                                    routeCount =
                                        Array.length data.company.routes

                                    nextFocus =
                                        if routeCount - 1 > focusIndex then
                                            Focused <| focusIndex

                                        else
                                            FocusedNew
                                in
                                data
                                    |> setRoutes (arrayRemoveAt focusIndex data.company.routes)
                                    |> setFocus nextFocus

                            else
                                data
                                    |> setRoutes (Array.set focusIndex newAmount data.company.routes)

                        ( newGame, persistCmd ) =
                            updateGameRoute model.game newData
                    in
                    ( { model
                        | lifecycle = Routes newData
                        , game = newGame
                      }
                    , persistCmd
                    )

                Nothing ->
                    -- error
                    ( model, Cmd.none )


closeNumpad : Model -> RoutesData -> ( Model, Cmd Msg )
closeNumpad model data =
    ( { model | lifecycle = Routes { data | focus = Unfocused } }
    , Cmd.none
    )


updateGameRoute : Game -> RoutesData -> ( Game, Cmd Msg )
updateGameRoute game routesData =
    let
        companyIndex =
            case routesData.company.id of
                CompanyId i ->
                    i

        newGame =
            { game
                | companies =
                    arrayUpdateAt
                        companyIndex
                        (\company ->
                            { company
                                | routes = routesData.company.routes
                            }
                        )
                        game.companies
            }
    in
    ( newGame, persistGame <| encodeGame newGame )
