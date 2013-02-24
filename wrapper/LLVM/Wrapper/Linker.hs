module LLVM.Wrapper.Linker ( LinkerMode(..)
                           , linkModules ) where

import qualified LLVM.FFI.Linker as FFI
import LLVM.FFI.Linker (LinkerMode(..))
import qualified LLVM.FFI.Core as FFI
import LLVM.Wrapper.Core

import Foreign.C.String (peekCString)
import Foreign.Marshal.Alloc (alloca)
import Foreign.Storable (peek)
import Foreign.ForeignPtr.Safe (withForeignPtr)

linkModules :: Module -> Module -> LinkerMode -> IO (Maybe String)
linkModules dest src mode =
    withForeignPtr dest $ \dest' ->
    withForeignPtr src $ \src' ->
    alloca (\msgPtr -> do
              result <- FFI.linkModules dest' src' (FFI.fromLinkerMode mode) msgPtr
              msg <- peek msgPtr
              case result of
                False -> return Nothing
                True -> do str <- peekCString msg
                           FFI.disposeMessage msg
                           return (Just str))