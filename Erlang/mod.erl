-module(mod).

-export([add/2, string_inc/1, temperature/1, reverse/1]).

-doc("Adds two numbers together.").
add(A, B) -> A + B.

string_inc(S) ->
    [inc(I) || I <- S].

inc(I) -> I + 1.

temperature(City) ->
    case City of
        "London" -> 12;
        "Paris" -> 16;
        {_, london} -> 14; % First argument can
        {_, S} -> S; % be a tuple
        _ -> undefined
    end .

% First argument is termination condition
reverse(L) -> reverse(L, []).

% reverse([], A) -> A.
reverse([H | T], A) ->
    reverse(T, [H | A]).

% 3> c(mod).
% {ok,mod}
% 4> mod:temperature("AA")
% 4> .
% undefined
% 5> mod:temperature("London").
% 12
% 6> mod:temperature("london").
% undefined


