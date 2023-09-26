module Sessions.Store where

import Codec.Serialise
import Data.ByteString.Lazy qualified as BSL
import GHC.Generics (Generic)

type UserData = Int

data UserSession = UserSession
    { id_ :: String
    , data_ :: UserData
    }
    deriving (Generic)

instance Serialise UserSession

type SessionId = String

data LocalSessionStore = LocalSessionStore
    { path :: FilePath
    }

writeGob :: Serialise a => FilePath -> a -> IO ()
writeGob filePath object = BSL.writeFile filePath (serialise object)

readGob :: Serialise a => FilePath -> IO a
readGob filePath = deserialise <$> BSL.readFile filePath

save :: LocalSessionStore -> UserSession -> IO ()
save s us = writeGob (path s ++ id_ us) us

load :: LocalSessionStore -> SessionId -> IO UserSession
load s id' = readGob (path s ++ id')
