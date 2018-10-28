{-# LANGUAGE NamedFieldPuns #-}

module Game.Context.Room(
    Room(..),
    RoomInputFunc,
    RoomRenderFunc,
    RoomUpdateFunc,
    RoomFunctions,
    makeRoom,
    playRoom,
    applyRules
) where

import Graphics.Gloss(Picture)
import Graphics.Gloss.Game
import Engine.Base
import Game.Structure.GameState
import Game.Rules.Rule

{- Data structures -}
data Room = Room {
    state :: GameState,
    initState :: GameState,
    rules :: [Rule],
    rInput :: RoomInputFunc,
    rRender :: RoomRenderFunc,
    rUpdate :: RoomUpdateFunc
}

type RoomInputFunc = (Event -> GameState -> GameState)
type RoomRenderFunc = (GameState -> Picture)
type RoomUpdateFunc = (Float -> GameState -> GameState)
type RoomFunctions = (RoomInputFunc, RoomRenderFunc, RoomUpdateFunc)

{- Instances -}
instance Inputable Room where
    input e r@Room{state, rInput} = r{state=nstate} where nstate = rInput e state

instance Renderable Room where
    render r@Room{state, rRender} = rRender state

instance BaseUpdateable Room where
    baseUpdate dt r@Room{rules, rUpdate, state} = r{state=nstate} where nstate = applyRules rules $ rUpdate dt state


{- Functions -}
makeRoom :: GameState -> [Rule] -> RoomFunctions -> Room
makeRoom istate rules (i,r,u) = Room istate istate rules i r u

playRoom f Room{ initState, rRender, rInput, rUpdate } =
    f initState rRender rInput [rUpdate]