module Engine.Audio.Loading (
  loadSound
) where
    
import qualified SDL
import qualified SDL.Mixer as Mix
import Engine.Audio.Sound
import Constants

    
{- Data structures -}


{- Classes -}


{- Instances -}


{- Functions -}
-- | Loads wav sound from given path to given channel and specified volume
loadSound :: String -> Integer -> Integer -> IO Sound
loadSound identifier channel volume = do
    snd <- Mix.load (resourceDir ++ identifier ++ ".wav")
    return $ Sound snd channel volume