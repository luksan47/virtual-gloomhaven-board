module BoardOverlay exposing (BoardOverlay, BoardOverlayDirectionType(..), BoardOverlayType(..), ChestType(..), CorridorMaterial(..), CorridorSize(..), DoorSubType(..), ObstacleSubType(..), TrapSubType(..), TreasureSubType(..), getBoardOverlayName)

import BoardMapTile exposing (MapTileRef)


type BoardOverlayType
    = StartingLocation
    | Door DoorSubType (List MapTileRef)
    | Trap TrapSubType
    | Obstacle ObstacleSubType
    | Treasure TreasureSubType



-- DifficultTerrain
-- Corridors


type DoorSubType
    = Corridor CorridorMaterial CorridorSize
    | DarkFog
    | Stone
    | Wooden


type CorridorMaterial
    = Earth
    | ManmadeStone
    | NaturalStone
    | Wood


type CorridorSize
    = One
    | Two


type TrapSubType
    = BearTrap
    | Spike


type ObstacleSubType
    = Sarcophagus
    | Boulder1
    | Boulder2
    | Bush
    | Nest
    | Table
    | Tree3


type TreasureSubType
    = Chest ChestType
    | Coin Int


type ChestType
    = NormalChest Int
    | Goal


type BoardOverlayDirectionType
    = Default
    | Horizontal
    | Vertical
    | DiagonalLeft
    | DiagonalRight


type alias BoardOverlay =
    { ref : BoardOverlayType
    , direction : BoardOverlayDirectionType
    , cells : List ( Int, Int )
    }


getBoardOverlayName : BoardOverlayType -> String
getBoardOverlayName overlay =
    case overlay of
        StartingLocation ->
            "starting-location"

        Door d _ ->
            case d of
                Stone ->
                    "door-stone"

                Wooden ->
                    "door-wooden"

                Corridor c num ->
                    (case c of
                        Earth ->
                            "corridor-earth"

                        ManmadeStone ->
                            "corridor-manmade-stone"

                        NaturalStone ->
                            "corridor-natural-stone"

                        Wood ->
                            "corridor-wood"
                    )
                        ++ (case num of
                                One ->
                                    "-1"

                                Two ->
                                    "-2"
                           )

                DarkFog ->
                    "door-dark-fog"

        Trap t ->
            case t of
                BearTrap ->
                    "trap-bear"

                Spike ->
                    "trap-spike"

        Obstacle o ->
            case o of
                Sarcophagus ->
                    "obstacle-sarcophagus"

                Boulder1 ->
                    "obstacle-boulder-1"

                Boulder2 ->
                    "obstacle-boulder-2"

                Bush ->
                    "obstacle-bush"

                Table ->
                    "obstacle-table"

                Nest ->
                    "obstacle-nest"

                Tree3 ->
                    "obstacle-tree-3"

        Treasure t ->
            case t of
                Chest _ ->
                    "treasure-chest"

                Coin _ ->
                    "treasure-coin"
