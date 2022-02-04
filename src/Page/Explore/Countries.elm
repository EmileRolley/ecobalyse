module Page.Explore.Countries exposing (details, view)

import Data.Country as Country exposing (Country)
import Data.Db as Db exposing (Db)
import Html exposing (..)
import Html.Attributes exposing (..)
import Route
import Views.Format as Format
import Views.Table as Table


table : { detailed : Bool } -> List { label : String, toCell : Country -> Html msg }
table { detailed } =
    [ { label = "Identifiant"
      , toCell =
            \country ->
                td []
                    [ if detailed then
                        code [] [ text (Country.codeToString country.code) ]

                      else
                        a [ Route.href (Route.Explore (Db.Countries (Just country.code))) ]
                            [ code [] [ text (Country.codeToString country.code) ] ]
                    ]
      }
    , { label = "Nom"
      , toCell = \country -> td [] [ text country.name ]
      }
    , { label = "Code"
      , toCell = \country -> td [] [ code [] [ text (Country.codeToString country.code) ] ]
      }
    , { label = "Nom"
      , toCell = \country -> td [] [ text country.name ]
      }
    , { label = "Mix éléctrique"
      , toCell = \country -> td [] [ text country.electricityProcess.name ]
      }
    , { label = "Chaleur"
      , toCell = \country -> td [] [ text country.heatProcess.name ]
      }
    , { label = "Majoration de teinture"
      , toCell = \country -> td [] [ Format.ratio country.dyeingWeighting ]
      }
    , { label = "Part du transport aérien"
      , toCell = \country -> td [] [ Format.ratio country.airTransportRatio ]
      }
    ]


details : Db -> Country -> Html msg
details _ country =
    Table.responsiveDefault [ class "view-details" ]
        [ table { detailed = True }
            |> List.map
                (\{ label, toCell } ->
                    tr []
                        [ th [] [ text label ]
                        , toCell country
                        ]
                )
            |> tbody []
        ]


view : List Country -> Html msg
view countrys =
    Table.responsiveDefault [ class "view-list" ]
        [ thead []
            [ table { detailed = False }
                |> List.map (\{ label } -> th [] [ text label ])
                |> tr []
            ]
        , countrys
            |> List.map
                (\country ->
                    table { detailed = False }
                        |> List.map (\{ toCell } -> toCell country)
                        |> tr []
                )
            |> tbody []
        ]
