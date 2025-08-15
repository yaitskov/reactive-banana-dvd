{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ApplicativeDo #-}
module Interview where

import Control.Concurrent
import Reactive.Banana
import Reactive.Banana.Frameworks
import Termbox.Banana as TB

import Relude



main :: IO ()
main = TB.run program >>= \case
  Left e -> fail $ show e
  Right _ -> pure ()


program :: Inputs -> MomentIO (Outputs Key)
program i = do
  (tickEvent, fireTickEvent) <- newEvent
  let ticker = do
        fireTickEvent ()
        threadDelay (10 ^ (5 :: Int))
        ticker
  liftIO $ forkIO ticker

  xPos :: Behavior Int <- accumB 0 ((+1) <$ tickEvent)
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
