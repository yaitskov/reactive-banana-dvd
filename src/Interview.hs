{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ApplicativeDo #-}
module Interview where

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
  effectiveSize <- stepper (initialSize i) (resizes i)
  let firstColumn :: Behavior (Int, Int) = (\es -> ((width es - txtLen) `div` 2, height es `div` 2)) <$> effectiveSize
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
