module Model exposing (..)

import Array exposing (Array)
import Element exposing (Color, Element)


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
