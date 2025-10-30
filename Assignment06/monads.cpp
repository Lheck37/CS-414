// Assignment06/monads.cpp
// simple example using std::optional and a small Result<T,E> class

#include <optional>
#include <variant>
#include <string>
#include <iostream>

// -------- optional helpers (Option monad style) --------
template<class A, class F>
auto maybe_bind(const std::optional<A>& m, F f) -> decltype(f(*m)) {
    if (!m) return decltype(f(*m)){};
    return f(*m);
}

template<class A>
std::optional<A> maybe_return(A x) {
    return std::optional<A>(std::move(x));
}

std::optional<int> safe_div(int a, int b) {
    if (b == 0) return std::nullopt;
    return a / b;
}

// chained safe division: (((x / y) / z) / 2)
std::optional<int> pipeline_opt(int x, int y, int z) {
    return maybe_bind(safe_div(x, y), [&](int a1) {
           return maybe_bind(safe_div(a1, z), [&](int a2) {
           return maybe_bind(safe_div(a2, 2), [&](int a3) {
               return maybe_return(a3);
           });});});
}

// -------- simple Result<T,E> implementation --------
template<class T, class E>
class Result {
    std::variant<T,E> data;
public:
    static Result ok(T v) { return Result(std::move(v)); }
    static Result err(E e) { return Result(std::move(e)); }

    bool is_ok() const { return std::holds_alternative<T>(data); }
    const T& value() const { return std::get<T>(data); }
    const E& error() const { return std::get<E>(data); }

private:
    Result(T v) : data(std::move(v)) {}
    Result(E e) : data(std::move(e)) {}

public:
    template<class F>
    auto bind(F f) const -> decltype(f(std::declval<T>())) {
        using R = decltype(f(std::declval<T>()));
        if (!is_ok()) return R::err(error());
        return f(value());
    }
};

// validators similar to OCaml Result examples
Result<int,std::string> parse_int(const std::string& s) {
    try {
        size_t idx = 0;
        int v = std::stoi(s, &idx);
        if (idx != s.size()) return Result<int,std::string>::err("extra chars");
        return Result<int,std::string>::ok(v);
    } catch (...) {
        return Result<int,std::string>::err("not an int");
    }
}

Result<int,std::string> nonneg(int x) {
    return x < 0 ? Result<int,std::string>::err("negative")
                 : Result<int,std::string>::ok(x);
}

Result<int,std::string> under100(int x) {
    return (x < 100) ? Result<int,std::string>::ok(x)
                     : Result<int,std::string>::err("too big");
}

Result<int,std::string> validate(const std::string& s) {
    return parse_int(s).bind(nonneg).bind(under100);
}

// --------------- main test ---------------
int main() {
    auto r1 = pipeline_opt(36, 2, 3); // ((36/2)/3)/2 = 3
    if (r1) std::cout << "Option pipeline result: " << *r1 << "\n";
    else std::cout << "Option pipeline failed\n";

    auto v1 = validate("42");
    if (v1.is_ok()) std::cout << "validate ok: " << v1.value() << "\n";
    else std::cout << "validate error: " << v1.error() << "\n";

    auto v2 = validate("-5");
    if (v2.is_ok()) std::cout << "validate ok: " << v2.value() << "\n";
    else std::cout << "validate error: " << v2.error() << "\n";

    return 0;
}
