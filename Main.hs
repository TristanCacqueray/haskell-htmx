{-# LANGUAGE OverloadedStrings, PartialTypeSignatures #-}
module Main where

import Sessions.Store
import Data.UUID
import Data.UUID.V4 qualified as UUID
import Data.Aeson
import Web.Scotty
import Web.Scotty.Cookie
import Data.Text.Encoding
import Data.ByteString (toStrict)
import Control.Monad.IO.Class

cookieName = "haskell-htmx-playground"

setCookie_ :: _ UUID
setCookie_ = do
  sessionUUID <- liftIO UUID.nextRandom
  let value = object ["uuid" .= sessionUUID]
  let encoded = toStrict (encode value)
  let cookie = makeSimpleCookie cookieName (decodeUtf8 encoded)
  setCookie cookie
  pure sessionUUID

readCookie_ :: _ (Maybe UUID)
readCookie_ = do
  mCookie <- getCookie cookieName
  case mCookie of
    Just cookie -> pure Nothing
    _ -> pure Nothing


rootHandler :: LocalSessionStore -> _ ()
rootHandler sessionStore = do
  mSessionUUID <- readCookie_
  sessionUUID <- case mSessionUUID of
    Just uid -> pure uid
    Nothing -> setCookie_

  -- retrieve user session

  -- execute htmx-index.html template
  html "<html>todo</html>"

clickHandler :: _ ()
clickHandler = do
  html "<div>Clicked</div>"
  liftIO $ putStrLn "Clicked"

main :: IO ()
main = do
  let localSessionStore = LocalSessionStore "data/sessions/"

  let rootHandlerSession = rootHandler localSessionStore

  scotty 3000 $ do
    get "/" rootHandlerSession
    post "/clicked" clickHandler
