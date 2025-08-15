# lazy-scope

lazy-scope library appeared as an attempt to improve lazy IO API from
[bytestring](https://hackage.haskell.org/package/bytestring)
package:

 - `hGetContents` closes handle which was open by somebody else.
 - `hGetContents` closes handle only on EOF

E.g. [git-phoenix](https://hackage.haskell.org/package/git-phoenix)
does GIT objects recovery. Recovered compressed file usually has
trailing trash bytes after archive ends. In such circumstance bracket
finalizer should check every handle before closing.

lazy-scope library provides `hGetContents` with alternative semantic -
it never close the handle! Handle and values, derived from it, have a
type parameter which prevents accidental thunk escape beyond open
handle scope.  Solution is based on
[ST](https://hackage.haskell.org/package/base/docs/Control-Monad-ST.html)
monad.


``` haskell
import Lazy.Scope qualified as S
import Relude

main = do
  r <- S.withBinaryFile "/etc/hosts" ReadMode S.hGetContents
  S.unsnoc r `seq` return ()
```
Error:
```
  • Couldn't match type ‘s0’ with ‘s’
    Expected: S.Handle s -> S.LazyT s IO (S.Bs s0)
      Actual: S.Handle s -> S.LazyT s IO (S.Bs s)
      because type variable ‘s’ would escape its scope
```

Correct version:

``` haskell
import Data.ByteString.Lazy qualified as LBS
import Lazy.Scope qualified as S
import Relude

main = do
  r <- S.withBinaryFile "/etc/hosts" ReadMode (S.hGetContents >=> S.toLbs)
  LBS.unsnoc r `seq` return ()
```

The package has scoped alternatives for majority of `Handle` and
`ByteString` functions from `System.IO` and `Data.ByteString.Lazy`
modules correspondingly.

## Development

Dev environment is provided by
[nix-shell](https://nixos.org/guides/nix-pills/10-developing-with-nix-shell.html)

``` shell
$ nix-shell
$ cabal test
```
