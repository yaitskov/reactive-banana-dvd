{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ApplicativeDo #-}
module Interview where

import Control.Concurrent ( threadDelay, forkIO )
import Reactive.Banana
import Reactive.Banana.Frameworks
import Relude
import Termbox.Banana as TB

main :: IO ()
main = TB.run program >>= \case
  Left e -> fail $ show e
  Right _ -> pure ()

program :: Inputs -> MomentIO (Outputs Key)
program i = do
  (tickEvent :: Event (), fireTickEvent) <- newEvent
  let ticker = do
        fireTickEvent ()
        threadDelay (10 ^ (6 :: Int))
        ticker
  liftIO $ forkIO ticker
  -- (<@>) :: Behavior (a -> b) -> Event a -> Event b
  -- (<@) :: Behavior b -> Event a -> Event b
  -- stepper :: MonadMoment m => a -> Event a -> m (Behavior a)
  -- whenE :: Behavior Bool -> Event a -> Event a
  -- accumB :: MonadMoment m => a -> Event (a -> a) -> m (Behavior a)
  -- filterE :: (a -> Bool) -> Event a -> Event a
  speed :: Behavior Int <- accumB 1 $ unions [ (\a -> a + 1) <$ filterE (==KeyArrowUp) (keys i)
                                             , (\a -> a - 1) <$ filterE (==KeyArrowDown) (keys i)
                                             ]
  xPos :: Behavior Int  <- accumB 0 ((+) <$> (speed <@ tickEvent))
  effectiveSize <- stepper (initialSize i) (resizes i)
  let firstColumn :: Behavior (Int, Int) = (\es x -> ((width es - txtLen) `div` 2, x `mod` height es)) <$> effectiveSize <*> xPos
  pure $ Outputs
    { scene =
        fmap s firstColumn
    , done =
        filterE (\x -> x == (KeyChar 'q')) $ keys i
    }
  where
    txt = "HELLO"
    txtLen = length txt

    s (fc, fr) =
      image $ fg white $ bg green $ atRow fr $ mconcat $ zipWith (\ii c -> atCol ii (TB.char c)) [fc + 1 ..] txt
