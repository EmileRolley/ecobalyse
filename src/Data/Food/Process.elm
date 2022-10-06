module Data.Food.Process exposing
    ( Code
    , Process
    , ProcessName
    , Processes
    , codeFromString
    , codeToString
    , decodeProcesses
    , emptyProcesses
    , findByCode
    , findByName
    , loadWellKnown
    , nameFromString
    , nameToString
    )

import Data.Impact as Impact
import Dict.Any as AnyDict exposing (AnyDict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Result.Extra as RE


{-| Process
A process is an entry from public/data/food/processes.json. It has impacts and
various other data like categories, code, unit...
-}
type alias Process =
    { name : ProcessName
    , impacts : Impact.Impacts
    , ciqualCode : Maybe Int
    , step : Maybe String
    , dqr : Maybe Float
    , emptyProcess : Bool
    , unit : String
    , code : Code
    , simaproCategory : String
    , systemDescription : String
    , categoryTags : List String
    }


type alias Processes =
    AnyDict String ProcessName Process


type Code
    = Code String


type ProcessName
    = ProcessName String


type alias WellKnown =
    { lorryTransport : Process
    , boatTransport : Process
    , planeTransport : Process
    }


codeFromString : String -> Code
codeFromString =
    Code


codeToString : Code -> String
codeToString (Code string) =
    string


nameFromString : String -> ProcessName
nameFromString =
    ProcessName


nameToString : ProcessName -> String
nameToString (ProcessName name) =
    name


decodeProcess : List Impact.Definition -> Decoder Process
decodeProcess definitions =
    Decode.succeed Process
        |> Pipe.hardcoded (nameFromString "to be defined")
        |> Pipe.required "impacts" (Impact.decodeImpacts definitions)
        |> Pipe.required "ciqual_code" (Decode.nullable Decode.int)
        |> Pipe.required "step" (Decode.nullable Decode.string)
        |> Pipe.required "dqr" (Decode.nullable Decode.float)
        |> Pipe.required "empty_process" Decode.bool
        |> Pipe.required "unit" (Decode.map formatStringUnit Decode.string)
        |> Pipe.required "code" (Decode.map codeFromString Decode.string)
        |> Pipe.required "simapro_category" Decode.string
        |> Pipe.required "system_description" Decode.string
        |> Pipe.required "category_tags" (Decode.list Decode.string)


decodeProcesses : List Impact.Definition -> Decoder Processes
decodeProcesses definitions =
    AnyDict.decode (\str _ -> ProcessName str) nameToString (decodeProcess definitions)
        |> Decode.map
            (AnyDict.map
                (\processName process ->
                    { process | name = processName }
                )
            )


emptyProcesses : Processes
emptyProcesses =
    AnyDict.empty nameToString


findByCode : Processes -> Code -> Result String Process
findByCode processes ((Code codeString) as code) =
    processes
        |> AnyDict.filter (\_ process -> process.code == code)
        |> AnyDict.toList
        |> List.head
        |> Maybe.map Tuple.second
        |> Result.fromMaybe ("Procédé introuvable par code : " ++ codeString)


findByName : Processes -> ProcessName -> Result String Process
findByName processes ((ProcessName name) as procName) =
    processes
        |> AnyDict.get procName
        |> Result.fromMaybe ("Procédé introuvable par nom : " ++ name)


formatStringUnit : String -> String
formatStringUnit str =
    case str of
        "cubic meter" ->
            "m³"

        "kilogram" ->
            "kg"

        "kilometer" ->
            "km"

        "kilowatt hour" ->
            "kWh"

        "litre" ->
            "l"

        "megajoule" ->
            "MJ"

        "ton kilometer" ->
            "t/km"

        _ ->
            str


loadWellKnown : Processes -> Result String WellKnown
loadWellKnown processes =
    let
        resolve code =
            RE.andMap (codeFromString code |> findByCode processes)
    in
    Ok WellKnown
        -- Transport, freight, lorry 16-32 metric ton, EURO5 {RER}| transport, freight, lorry 16-32 metric ton, EURO5 | Cut-off, S - Copied from Ecoinvent
        |> resolve "c24fc476f6d5237aa2c58d7d95bc1ca4"
        -- Transport, freight, sea, transoceanic ship {GLO}| processing | Cut-off, S - Copied from Ecoinvent
        |> resolve "958bbb33cf6cdb8e3c8d4f21aec5ef98"
        -- Transport, freight, aircraft {RER}| intercontinental | Cut-off, S - Copied from Ecoinvent
        |> resolve "5bc527741ac919ff8710a474f849614f"