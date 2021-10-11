module Data.Gitbook exposing (..)

import Json.Decode as Decode exposing (Decoder)


type alias Page =
    { title : String
    , description : Maybe String
    , markdown : String
    , path : String
    }


cleanMarkdown : String -> String
cleanMarkdown =
    -- Map Gitbook formulas to standard preformatted code blocks
    String.replace "$$" "```"
        -- Map Gitbook hints to bootstrap alerts
        >> String.replace "{% hint style=\"danger\" %}" "<hint level=\"danger\">"
        >> String.replace "{% hint style=\"warning\" %}" "<hint level=\"warning\">"
        >> String.replace "{% hint style=\"info\" %}" "<hint level=\"info\">"
        >> String.replace "{% endhint %}" "</hint>"


publicUrl : String -> String
publicUrl path =
    "https://fabrique-numerique.gitbook.io/wikicarbone/" ++ path


decodeMaybeString : Decoder (Maybe String)
decodeMaybeString =
    Decode.maybe Decode.string
        |> Decode.andThen
            (\maybeString ->
                case maybeString of
                    Just string ->
                        if String.trim string == "" then
                            Decode.succeed Nothing

                        else
                            Decode.succeed (Just string)

                    Nothing ->
                        Decode.succeed Nothing
            )


decodePage : String -> Decoder Page
decodePage path =
    Decode.map4 Page
        (Decode.field "title" Decode.string)
        (Decode.field "description" decodeMaybeString)
        (Decode.field "document" Decode.string)
        (Decode.succeed path)