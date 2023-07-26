module Views.View exposing (..)

import Browser
import Element exposing (..)
import FontAwesome.Styles
import Model exposing (..)
import Views.Companies exposing (companyUi)
import Views.Routes exposing (routesUi)
import Views.Welcome exposing (welcomeUi)


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
                    welcomeUi model.assets

                Routes routesData ->
                    routesUi model.game routesData

                Companies ->
                    companyUi model.windowDimensions model.game
    in
    { title = pageUi.title
    , body =
        el
            [ width fill
            , height fill
            ]
            pageUi.body
    , modal = pageUi.modal
    }
