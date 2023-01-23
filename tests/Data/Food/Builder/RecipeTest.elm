module Data.Food.Builder.RecipeTest exposing (..)

import Data.Food.Builder.Query as Query
import Data.Food.Builder.Recipe as Recipe
import Data.Food.Ingredient as Ingredient
import Data.Food.Process as Process
import Data.Unit as Unit
import Dict
import Dict.Any as AnyDict
import Expect
import Mass
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


suite : Test
suite =
    let
        exampleQuery =
            Query.carrotCake
    in
    suiteWithDb "Data.Food.Builder.Recipe"
        (\{ builderDb } ->
            [ let
                recipe =
                    exampleQuery
                        |> Recipe.fromQuery builderDb
              in
              describe "fromQuery"
                [ recipe
                    |> Expect.ok
                    |> asTest "should return an Ok for a valid query"
                , { exampleQuery
                    | transform =
                        Just
                            { code = Process.codeFromString "not a process"
                            , mass = Mass.kilograms 0
                            }
                  }
                    |> Recipe.fromQuery builderDb
                    |> Result.map .transform
                    |> Expect.err
                    |> asTest "should return an Err for an invalid processing"
                ]
            , describe "compute"
                [ exampleQuery
                    |> Recipe.compute builderDb
                    |> Result.map (Tuple.second >> .total >> AnyDict.toDict)
                    |> Result.withDefault Dict.empty
                    |> Dict.map (\_ v -> Unit.impactToFloat v > 0)
                    |> Expect.equal
                        (Dict.fromList
                            -- Note: presented that way to ease diff viewing in test results
                            [ ( "acd", True )
                            , ( "bvi", True )
                            , ( "cch", True )
                            , ( "ecs", True )
                            , ( "etf", True )
                            , ( "fru", True )
                            , ( "fwe", True )
                            , ( "htc", True )
                            , ( "htn", True )
                            , ( "ior", True )
                            , ( "ldu", True )
                            , ( "mru", True )
                            , ( "ozd", True )
                            , ( "pco", True )
                            , ( "pef", True )
                            , ( "pma", True )
                            , ( "swe", True )
                            , ( "tre", True )
                            , ( "wtu", True )
                            ]
                        )
                    |> asTest "should return computed impacts where none equals zero"
                ]
            , describe "getTransformedIngredientsMass"
                [ { ingredients =
                        [ { id = Ingredient.idFromString "egg"
                          , name = "Oeuf"
                          , mass = Mass.grams 120
                          , variant = Query.Default
                          , country = Nothing
                          }
                        , { id = Ingredient.idFromString "wheat"
                          , name = "Blé tendre"
                          , mass = Mass.grams 140
                          , variant = Query.Default
                          , country = Nothing
                          }
                        ]
                  , transform = Nothing
                  , packaging = []
                  }
                    |> Recipe.compute builderDb
                    |> Result.map (Tuple.first >> Recipe.getMassAtPackaging)
                    |> Expect.equal (Ok (Mass.kilograms 0.26))
                    |> asTest "should compute recipe ingredients mass with no cooking involved"
                , exampleQuery
                    |> Recipe.compute builderDb
                    |> Result.map (Tuple.first >> Recipe.getMassAtPackaging)
                    |> Expect.equal (Ok (Mass.kilograms 0.79074))
                    |> asTest "should compute recipe ingredients mass applying raw to cooked ratio"
                ]
            ]
        )
