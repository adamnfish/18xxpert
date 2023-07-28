module Model exposing (..)

import Array exposing (Array)
import Element exposing (Color, Element)
import Json.Decode
import Json.Decode.Pipeline exposing (required)
import Json.Encode


type alias Flags =
    { assets : Assets
    , viewport : WindowDimensions
    }


type alias Model =
    { lifecycle : Lifecycle
    , assets : Assets
    , game : Game
    , windowDimensions : WindowDimensions
    }


type alias Assets =
    { logo : String
    }


type alias Game =
    { companies : Array Company
    }


type alias WindowDimensions =
    { width : Int
    , height : Int
    }


type Lifecycle
    = Welcome
    | Companies
    | Routes RoutesData


type alias RoutesData =
    { focus : Focus
    , company : Company
    }


type alias Company =
    { routes : Array Int
    , colourInfo : CompanyColour
    , id : CompanyId
    }


type CompanyId
    = CompanyId Int


type alias CompanyColour =
    { colour : Color
    , name : String
    , textBrightness : TextBrightness
    }


type TextBrightness
    = Dark
    | Light


type Focus
    = Focused Int
    | FocusedNew
    | Unfocused


type alias Ui =
    { title : String
    , body : Element Msg
    , modal : Maybe (Element Msg)
    }



-- Messages


type Msg
    = NoOp
    | Resized { width : Int, height : Int }
    | Start
    | NavMsg NavMsg
    | CompanyMsg CompanyMsg
    | RoutesMsg RoutesMsg
    | UpdateGameFromStorage Json.Encode.Value
    | RequestPersistedGame


type NavMsg
    = GoToWelcome
    | GoToCompanies
    | SelectCompany CompanyId


type CompanyMsg
    = AddCompany CompanyColour
    | DeleteCompany CompanyId


type RoutesMsg
    = NumpadEntry Int
    | NumpadBackspace
    | FocusRoute Int
    | FocusOnNewRoute
    | DeleteRoute Int
    | CloseNumpad



-- CODECS


encodeGame : Game -> Json.Encode.Value
encodeGame game =
    Json.Encode.object <|
        [ ( "companies", Json.Encode.array encodeCompany game.companies )
        ]


encodeColor : Color -> Json.Encode.Value
encodeColor colour =
    let
        rgb =
            Element.toRgb colour
    in
    Json.Encode.object
        [ ( "red", Json.Encode.float rgb.red )
        , ( "green", Json.Encode.float rgb.green )
        , ( "blue", Json.Encode.float rgb.blue )
        , ( "alpha", Json.Encode.float rgb.alpha )
        ]


encodeTextBrightness : TextBrightness -> Json.Encode.Value
encodeTextBrightness textBrightness =
    case textBrightness of
        Dark ->
            Json.Encode.string "Dark"

        Light ->
            Json.Encode.string "Light"


encodeCompanyColour : CompanyColour -> Json.Encode.Value
encodeCompanyColour companyColour =
    Json.Encode.object <|
        [ ( "colour", encodeColor companyColour.colour )
        , ( "name", Json.Encode.string companyColour.name )
        , ( "textBrightness", encodeTextBrightness companyColour.textBrightness )
        ]


encodeCompanyId : CompanyId -> Json.Encode.Value
encodeCompanyId (CompanyId int) =
    Json.Encode.int int


encodeCompany : Company -> Json.Encode.Value
encodeCompany company =
    Json.Encode.object <|
        [ ( "routes", Json.Encode.array Json.Encode.int company.routes )
        , ( "colourInfo", encodeCompanyColour company.colourInfo )
        , ( "id", encodeCompanyId company.id )
        ]


gameDecoder : Json.Decode.Decoder Game
gameDecoder =
    Json.Decode.succeed Game
        |> required "companies" (Json.Decode.array companyDecoder)


colorDecoder : Json.Decode.Decoder Color
colorDecoder =
    Json.Decode.succeed
        (\r g b a ->
            Element.fromRgb
                { red = r
                , green = g
                , blue = b
                , alpha = a
                }
        )
        |> required "red" Json.Decode.float
        |> required "green" Json.Decode.float
        |> required "blue" Json.Decode.float
        |> required "alpha" Json.Decode.float


textBrightnessDecoder : Json.Decode.Decoder TextBrightness
textBrightnessDecoder =
    let
        get id =
            case id of
                "Dark" ->
                    Json.Decode.succeed Dark

                "Light" ->
                    Json.Decode.succeed Light

                _ ->
                    Json.Decode.fail ("unknown value for TextBrightness: " ++ id)
    in
    Json.Decode.string |> Json.Decode.andThen get


companyColourDecoder : Json.Decode.Decoder CompanyColour
companyColourDecoder =
    Json.Decode.succeed CompanyColour
        |> required "colour" colorDecoder
        |> required "name" Json.Decode.string
        |> required "textBrightness" textBrightnessDecoder


companyIdDecoder : Json.Decode.Decoder CompanyId
companyIdDecoder =
    Json.Decode.map CompanyId Json.Decode.int


companyDecoder : Json.Decode.Decoder Company
companyDecoder =
    Json.Decode.succeed Company
        |> required "routes" (Json.Decode.array Json.Decode.int)
        |> required "colourInfo" companyColourDecoder
        |> required "id" companyIdDecoder
