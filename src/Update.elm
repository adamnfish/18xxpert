module Update exposing (..)

import Array
import Browser.Dom
import Element exposing (rgb255)
import Model exposing (..)
import Task
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
                                    in
                                    ( { model
                                        | lifecycle = Routes newRoutesData
                                        , game = updateGameRoute model.game newRoutesData
                                      }
                                    , Cmd.none
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
                                            in
                                            ( { model
                                                | lifecycle = Routes newRoutesData
                                                , game = updateGameRoute model.game newRoutesData
                                              }
                                            , Cmd.none
                                            )

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
                            in
                            ( { model
                                | lifecycle = Routes newData
                                , game = updateGameRoute model.game newData
                              }
                            , Cmd.none
                            )

                        NumpadBackspace ->
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
                                                        data
                                                            |> setRoutes (arrayRemoveAt focusIndex data.company.routes)
                                                            |> setFocus FocusedNew

                                                    else
                                                        data
                                                            |> setRoutes (Array.set focusIndex newAmount data.company.routes)
                                            in
                                            ( { model
                                                | lifecycle = Routes newData
                                                , game = updateGameRoute model.game newData
                                              }
                                            , Cmd.none
                                            )

                                        Nothing ->
                                            -- error
                                            ( model, Cmd.none )

                        CloseNumpad ->
                            -- todo: use focus maybe properly
                            ( { model | lifecycle = Routes { data | focus = Unfocused } }
                            , Cmd.none
                            )

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
                                , game = { game | companies = Array.push { routes = Array.empty, colourInfo = colourInfo, id = CompanyId <| Array.length model.game.companies } model.game.companies }
                              }
                            , Cmd.none
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
                            , Cmd.none
                            )


updateGameRoute : Game -> RoutesData -> Game
updateGameRoute game routesData =
    let
        companyIndex =
            case routesData.company.id of
                CompanyId i ->
                    i
    in
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
