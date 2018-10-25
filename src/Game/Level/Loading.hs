module Game.Level.Loading (
    readLevel
) where

import qualified Data.Vector as Vec
import Engine.Core.Coordinate
import Engine.Graphics.Sprite
import Game.Level.Level
import Resources
import Constants

    
{- Data structures -}
data IsWallTile = Wall Tile | NotWall Tile deriving (Show, Eq)


data TileMatcher = TileMatcher {
                      none, up, down, left, right, upLeft, upRight, downLeft, downRight :: IsWallTile
                   } deriving (Show)


{- Classes -}


{- Instances -}


{- Functions -}
-- Split this into level loading
-- | Reads raw level into a character map
readRawLevel :: String -> IO [[Char]]
readRawLevel file = do contents <- readFile file
                       return (lines contents)

-- | Parses a tile from a char
parseTile :: Char -> Tile
parseTile char = case char of '#' -> TileWall createEmptySprite
                              '.' -> TilePowerup PacDot
                              '@' -> TilePowerup PowerPill
                              '_' -> TileDoor
                              'u' -> TileWall spriteTileSStraightU
                              'd' -> TileWall spriteTileSStraightD
                              'l' -> TileWall spriteTileSStraightL
                              'r' -> TileWall spriteTileSStraightR
                              _   -> TileEmpty

-- | Creates table from given list of lists of a type
createTable :: [[a]] -> Table a
createTable input = Table tableData width height
                    where tableData = Vec.fromList (map Vec.fromList input)
                          height = Vec.length tableData
                          width | height > 0 = Vec.length (tableData Vec.! 1)
                                | otherwise  = 0

-- | Parses level from character table
parseLevel :: [[Char]] -> Level
parseLevel rawLevel = Level (createTable tiles)
                      where tiles = map (map parseTile) rawLevel

updateLevelWalls :: Level -> Level
updateLevelWalls l@(Level (Table vec w h)) = Level (Table nvec w h)
                                             where nvec = Vec.fromList [nrow y | y <- [0.. h-1]]
                                                   nrow y = Vec.fromList [ntile (Pos x y) | x <- [0.. w-1]]
                                                   ntile p = matchWallSprite (createTileMatcher p l)



-- | Reads level from a file. Warning IO
readLevel :: String -> IO Level
readLevel file = do rawLevel <- readRawLevel file
                    return (updateLevelWalls (updateLevelWalls (parseLevel rawLevel)))



-- LEVEL DECORATION =====================================

createTileMatcher :: Pos -> Level -> TileMatcher
createTileMatcher p (Level t) = TileMatcher{
                                    none      = isWallTile $ t ! p,
                                    up        = isWallTile $ t ! (p + Pos 0    (-1)),
                                    down      = isWallTile $ t ! (p + Pos 0    1),
                                    left      = isWallTile $ t ! (p + Pos (-1) 0),
                                    right     = isWallTile $ t ! (p + Pos 1    0),
                                    upLeft    = isWallTile $ t ! (p + Pos (-1) (-1)),
                                    upRight   = isWallTile $ t ! (p + Pos 1    (-1)),
                                    downLeft  = isWallTile $ t ! (p + Pos (-1) 1),
                                    downRight = isWallTile $ t ! (p + Pos 1    1)
                                }

isWallTile :: Tile -> IsWallTile
isWallTile t@(TileWall a) = Wall t
isWallTile t = NotWall t


-- This is an abomination. Do I need to say more? Still though spriting while making level is for losers
matchWallSprite :: TileMatcher -> Tile
matchWallSprite TileMatcher{none=Wall _, left = Wall lw, right = NotWall _, up = Wall uw, down = NotWall _}
    | lw == TileWall spriteTileSStraightD && uw == TileWall spriteTileSStraightR = TileWall spriteTileSCornerLU
    | otherwise = TileWall spriteTileFCornerLUUL
matchWallSprite TileMatcher{none=Wall _, left = NotWall _, right = Wall rw, up = Wall uw, down = NotWall _}
    | rw == TileWall spriteTileSStraightD && uw == TileWall spriteTileSStraightL = TileWall spriteTileSCornerRU
    | otherwise = TileWall spriteTileFCornerRUUR
matchWallSprite TileMatcher{none=Wall _, left = Wall lw, right = NotWall _, up = NotWall _, down = Wall dw}
    | lw == TileWall spriteTileSStraightU && dw == TileWall spriteTileSStraightR = TileWall spriteTileSCornerLD
    | otherwise = TileWall spriteTileFCornerLDDL
matchWallSprite TileMatcher{none=Wall _, left = NotWall _, right = Wall rw, up = NotWall _, down = Wall dw}
    | rw == TileWall spriteTileSStraightU && dw == TileWall spriteTileSStraightL = TileWall spriteTileSCornerRD
    | otherwise = TileWall spriteTileFCornerRDDR

matchWallSprite TileMatcher{none=Wall _, left = Wall _, right = NotWall _, up = NotWall _, down = Wall _, upRight = NotWall _, downLeft = NotWall _} = TileWall spriteTileSCornerLD
matchWallSprite TileMatcher{none=Wall _, left = NotWall _, right = Wall _, up = NotWall _, down = Wall _, upLeft = NotWall _, downRight = NotWall _ } = TileWall spriteTileSCornerRD
matchWallSprite TileMatcher{none=Wall _, left = Wall _, right = NotWall _, up = Wall _, down = NotWall _, upLeft = NotWall _, downRight = NotWall _ } = TileWall spriteTileSCornerLU
matchWallSprite TileMatcher{none=Wall _, left = NotWall _, right = Wall _, up = Wall _, down = NotWall _, upRight = NotWall _, downRight = NotWall _ } = TileWall spriteTileSCornerRU

matchWallSprite TileMatcher{none=Wall _, left = Wall _, right = NotWall _, up = Wall _, down = Wall _, upRight = NotWall _, upLeft = NotWall _} = TileWall spriteTileSSplitUDL
matchWallSprite TileMatcher{none=Wall _, left = NotWall _, right = Wall _, up = Wall _, down = Wall _, upRight = NotWall _, upLeft = NotWall _} = TileWall spriteTileSSplitUDR
matchWallSprite TileMatcher{none=Wall _, left = Wall _, right = NotWall _, up = Wall _, down = Wall _, downRight = NotWall _, downLeft = NotWall _} = TileWall spriteTileSSplitDUL
matchWallSprite TileMatcher{none=Wall _, left = NotWall _, right = Wall _, up = Wall _, down = Wall _, downRight = NotWall _, downLeft = NotWall _} = TileWall spriteTileSSplitDUR
matchWallSprite TileMatcher{none=Wall _, left = Wall _, right = Wall _, up = NotWall _, down = Wall _, downRight = Wall _, downLeft = NotWall _} = TileWall spriteTileSSplitLRD
matchWallSprite TileMatcher{none=Wall _, left = Wall _, right = Wall _, up = NotWall _, down = Wall _, downRight = NotWall _, downLeft = Wall _} = TileWall spriteTileSSplitRLD

matchWallSprite TileMatcher{none=Wall _, left = Wall _, upLeft = NotWall _, up = Wall _} = TileWall spriteTileFCornerLUUL
matchWallSprite TileMatcher{none=Wall _, right = Wall _, upRight = NotWall _, up = Wall _} = TileWall spriteTileFCornerRUUR
matchWallSprite TileMatcher{none=Wall _, left = Wall _, downLeft = NotWall _, down = Wall _} = TileWall spriteTileFCornerLDDL
matchWallSprite TileMatcher{none=Wall _, right = Wall _, downRight = NotWall _, down = Wall _} = TileWall spriteTileFCornerRDDR

matchWallSprite TileMatcher{none=Wall _, left = Wall _, right = Wall _, up = NotWall _, down = Wall _} = TileWall spriteTileFStraightD
matchWallSprite TileMatcher{none=Wall _, left = Wall _, right = Wall _, up = NotWall _, down = Wall _} = TileWall spriteTileFStraightD
matchWallSprite TileMatcher{none=Wall _, left = Wall _, right = Wall _, up = Wall _, down = NotWall _} = TileWall spriteTileFStraightU
matchWallSprite TileMatcher{none=Wall _, left = Wall _, right = NotWall _, up = Wall _, down = Wall _} = TileWall spriteTileFStraightL
matchWallSprite TileMatcher{none=Wall _, left = NotWall _, right = Wall _, up = Wall _, down = Wall _} = TileWall spriteTileFStraightR

matchWallSprite TileMatcher{none=Wall _, left = Wall lw, right = NotWall TileEmpty, up = NotWall _, down = NotWall _, upLeft = NotWall _, downLeft = NotWall _} = lw
matchWallSprite TileMatcher{none=Wall _, left = NotWall TileEmpty, right = Wall rw, up = NotWall _, down = NotWall _, upRight = NotWall _, downRight = NotWall _} = rw

matchWallSprite TileMatcher{none=Wall _, left = Wall lw, right = NotWall TileDoor, up = NotWall _, down = NotWall _, upLeft = NotWall _, downLeft = NotWall _} = TileWall spriteTileCEndR
matchWallSprite TileMatcher{none=Wall _, left = NotWall TileDoor, right = Wall rw, up = NotWall _, down = NotWall _, upRight = NotWall _, downRight = NotWall _} = TileWall spriteTileCEndL

matchWallSprite TileMatcher{none=Wall r} = r
matchWallSprite TileMatcher{none=NotWall r} = r