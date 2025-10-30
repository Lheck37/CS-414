# Assignment 06 – Monads in OCaml and C++

For this assignment I created simple examples of the Option, Result, and List monads in OCaml. Each one follows the same pattern of having a `return` 
function that wraps a value and a `bind` function that lets you chain computations together. I kept the code short so it’s easy to follow when looking 
at how the `let*` operator works with safe division examples.

In the C++ version I used `std::optional` as a rough version of the Option monad and built a small `Result<T,E>` class using `std::variant`. It lets me 
return either a success value or an error string, similar to OCaml’s `Result` type. I also chained safe divisions and value checks using small helper functions 
like `maybe_bind` and `validate`.

Both languages are doing the same idea: keeping code pure and predictable by wrapping values inside a context instead of using exceptions. OCaml’s syntax is cleaner with 
`let*`, while C++ needs more boilerplate, but they accomplish the same thing.

