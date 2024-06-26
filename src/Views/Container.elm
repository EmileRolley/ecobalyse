module Views.Container exposing
    ( centered
    , fluid
    )

import Html exposing (..)
import Html.Attributes exposing (..)


centered : List (Attribute msg) -> List (Html msg) -> Html msg
centered attrs =
    div (class "container" :: attrs)


fluid : List (Attribute msg) -> List (Html msg) -> Html msg
fluid attrs =
    div (class "container-fluid" :: attrs)
