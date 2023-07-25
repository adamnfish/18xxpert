module Update exposing (..)

import Array
import Element exposing (rgb255)
import Model exposing (..)
import Utilities exposing (arrayRemoveAt, arrayUpdateAt)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

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

                GoToRoutes (CompanyId companyId) ->
                    case Array.get companyId model.game.companies of
                        Just company ->
                            ( { model
                                | lifecycle =
                                    Routes
                                        { routes = company.routes
                                        , focus = Unfocused
                                        , companyId = company.id
                                        }
                              }
                            , Cmd.none
                            )

                        Nothing ->
                            -- error
                            ( model, Cmd.none )

                SelectCompany (CompanyId companyId) ->
                    case Array.get companyId model.game.companies of
                        Just company ->
                            ( { model
                                | lifecycle =
                                    Routes
                                        { routes = company.routes
                                        , focus = Unfocused
                                        , companyId = company.id
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
                                            Array.push n data.routes

                                        newRoutesData =
                                            { data
                                                | routes = newRoutes
                                                , focus = Focused <| Array.length data.routes
                                            }
                                    in
                                    ( { model
                                        | lifecycle = Routes newRoutesData
                                        , game = updateGameRoute model.game newRoutesData
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

                                                newRoutesData =
                                                    { data | routes = newRoutes }
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
                                    case Array.get focusIndex data.routes of
                                        Just currentAmount ->
                                            let
                                                newAmount =
                                                    currentAmount // 10

                                                newData =
                                                    if newAmount == 0 then
                                                        { data
                                                            | routes = arrayRemoveAt focusIndex data.routes
                                                            , focus = FocusedNew
                                                        }

                                                    else
                                                        { data
                                                            | routes = Array.set focusIndex newAmount data.routes
                                                        }
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
                        AddCompany colour ->
                            let
                                game =
                                    model.game
                            in
                            ( { model
                                | lifecycle =
                                    Routes
                                        { routes = Array.empty
                                        , focus = Unfocused
                                        , companyId = CompanyId <| Array.length model.game.companies
                                        }
                                , game = { game | companies = Array.push { routes = Array.empty, colour = colour, id = CompanyId <| Array.length model.game.companies } model.game.companies }
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
            case routesData.companyId of
                CompanyId i ->
                    i
    in
    { game
        | companies =
            arrayUpdateAt
                companyIndex
                (\company ->
                    { company
                        | routes = routesData.routes
                    }
                )
                game.companies
    }
