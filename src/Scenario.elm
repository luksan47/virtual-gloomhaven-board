module Scenario exposing (BoardBounds, DoorData(..), MapTileData, Scenario, ScenarioMonster, mapTileDataToList, mapTileDataToOverlayList)

import BoardMapTile exposing (MapTile, MapTileRef, getMapTileListByRef, refToString)
import BoardOverlay exposing (BoardOverlay, BoardOverlayType(..), DoorSubType)
import Dict exposing (Dict, empty, singleton, union)
import Hexagon exposing (rotate)
import Monster exposing (Monster, MonsterLevel)


type alias BoardBounds =
    { minX : Int
    , maxX : Int
    , minY : Int
    , maxY : Int
    }


type alias MapTileData =
    { ref : MapTileRef
    , doors : List DoorData
    , overlays : List BoardOverlay
    , monsters : List ScenarioMonster
    , turns : Int
    }


type DoorData
    = DoorLink DoorSubType ( Int, Int ) ( Int, Int ) MapTileData


type alias ScenarioMonster =
    { monster : Monster
    , initialX : Int
    , initialY : Int
    , twoPlayer : MonsterLevel
    , threePlayer : MonsterLevel
    , fourPlayer : MonsterLevel
    }


type alias Scenario =
    { id : Int
    , title : String
    , mapTilesData : MapTileData
    , angle : Float
    }


mapTileDataToOverlayList : MapTileData -> Dict String ( List BoardOverlay, List ScenarioMonster )
mapTileDataToOverlayList data =
    let
        initData =
            ( data.overlays
                ++ List.map
                    (\d ->
                        case d of
                            DoorLink subType ( x, y ) _ _ ->
                                BoardOverlay (Door subType) ( ( x, y ), Nothing )
                    )
                    data.doors
            , data.monsters
            )
                |> singleton (refToString data.ref)

        doorData =
            List.map
                (\d ->
                    case d of
                        DoorLink _ _ _ map ->
                            mapTileDataToOverlayList map
                )
                data.doors
                |> List.foldl (\a b -> union a b) empty
    in
    union initData doorData


mapTileDataToList : MapTileData -> Maybe ( ( Int, Int ), ( Int, Int ) ) -> ( List MapTile, BoardBounds )
mapTileDataToList data maybeTurnAxis =
    let
        mapTiles =
            let
                ( refPoint, origin ) =
                    case maybeTurnAxis of
                        Just ( r, o ) ->
                            ( r, o )

                        Nothing ->
                            ( ( 0, 0 ), ( 0, 0 ) )
            in
            getMapTileListByRef data.ref
                |> List.map (normaliseAndRotateMapTile data.turns refPoint origin)

        doorTiles =
            List.map mapDoorDataToList data.doors
                |> List.concat

        allTiles =
            mapTiles ++ doorTiles

        boundingBox =
            List.map (\m -> BoardBounds m.x m.x m.y m.y) allTiles
                |> List.foldl
                    (\a b -> BoardBounds (min a.minX b.minX) (max a.maxX b.maxX) (min a.minY b.minY) (max a.maxY b.maxY))
                    (BoardBounds 0 0 0 0)
    in
    ( allTiles, boundingBox )


mapDoorDataToList : DoorData -> List MapTile
mapDoorDataToList doorData =
    case doorData of
        DoorLink _ refPoint origin mapTileData ->
            Tuple.first (mapTileDataToList mapTileData (Just ( refPoint, origin )))


normaliseAndRotateMapTile : Int -> ( Int, Int ) -> ( Int, Int ) -> MapTile -> MapTile
normaliseAndRotateMapTile turns ( refPointX, refPointY ) ( originX, originY ) mapTile =
    let
        initX =
            mapTile.x - originX + refPointX

        initY =
            mapTile.y - originY + refPointY

        ( rotatedX, rotatedY ) =
            Hexagon.rotate ( initX, initY ) ( refPointX, refPointY ) turns
    in
    { mapTile | x = rotatedX, y = rotatedY, turns = turns }