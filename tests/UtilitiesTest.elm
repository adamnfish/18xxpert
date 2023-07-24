module UtilitiesTest exposing (..)

import Array
import Expect
import Test exposing (Test, describe, test)
import Utilities exposing (arrayRemoveAt)


suite : Test
suite =
    describe "utilities"
        [ describe "arrayRemoveAt"
            [ test "removes first element" <|
                \_ ->
                    arrayRemoveAt 0 (Array.fromList [ 1, 2, 3 ])
                        |> Expect.equal (Array.fromList [ 2, 3 ])
            , test "removes second element" <|
                \_ ->
                    arrayRemoveAt 1 (Array.fromList [ 1, 2, 3 ])
                        |> Expect.equal (Array.fromList [ 1, 3 ])
            , test "removes last element" <|
                \_ ->
                    arrayRemoveAt 2 (Array.fromList [ 1, 2, 3 ])
                        |> Expect.equal (Array.fromList [ 1, 2 ])
            , test "returns original array with out of bounds (low)" <|
                \_ ->
                    arrayRemoveAt -1 (Array.fromList [ 1, 2, 3 ])
                        |> Expect.equal (Array.fromList [ 1, 2, 3 ])
            , test "returns original array with out of bounds (high)" <|
                \_ ->
                    arrayRemoveAt 5 (Array.fromList [ 1, 2, 3 ])
                        |> Expect.equal (Array.fromList [ 1, 2, 3 ])
            ]
        ]
