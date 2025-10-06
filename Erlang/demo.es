#!/usr/bin/env escript

main([]) ->
    io:format(standard_error, "Usage: ~s <num1> <num2> ...~n", [escript:script_name()]);

main(Args) ->
    Sum = lists:sum([list_to_integer(I) || I <- Args]),
    io:format("Sum is ~w\n", [Sum]).
