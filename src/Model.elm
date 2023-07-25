module Model exposing (..)

import Array exposing (Array)
import Element exposing (Color, Element)


type alias Flags =
    { assets : Assets
    }



-- MODEL


type alias Model =
    { lifecycle : Lifecycle
    , assets : Assets
    , game : Game
    }


type alias Assets =
    { logo : String
    }


type alias Game =
    { companies : Array Company
    }


type Lifecycle
    = Welcome
    | Companies
    | Routes RoutesData


type alias RoutesData =
    { routes : Array Int
    , focus : Focus
    , companyId : CompanyId
    }


type alias Company =
    { routes : Array Int
    , colour : Color
    , id : CompanyId
    }


type CompanyId
    = CompanyId Int


type Focus
    = Focused Int
    | FocusedNew
    | Unfocused



-- View models


type alias Ui =
    { title : String
    , body : Element Msg
    , modal : Maybe (Element Msg)
    }



-- Messages


type Msg
    = NoOp
    | Start
    | NavMsg NavMsg
    | CompanyMsg CompanyMsg
    | RoutesMsg RoutesMsg


type NavMsg
    = GoToWelcome
    | GoToCompanies
    | GoToRoutes CompanyId
    | SelectCompany CompanyId


type CompanyMsg
    = AddCompany Color
    | DeleteCompany CompanyId


type RoutesMsg
    = NumpadEntry Int
    | NumpadBackspace
    | FocusRoute Int
    | FocusOnNewRoute
    | DeleteRoute Int
    | CloseNumpad
