%%%=============================================================================
%%% @author Alexej Tessaro <alexej.tessaro@gmail.com>
%%% @doc The module managing triangles.
%%%
%%% @end
%%%=============================================================================

-module(triangle).

-ifdef(TEST).
-include_lib("eqc/include/eqc.hrl").
-include_lib("eunit/include/eunit.hrl").
-endif.

-export([is_triangle/3]).

-export_type([]).

-define(is_pos_number(N), (is_number(N) andalso (N > 0))).

%% ===================================================================
%%  API
%% ===================================================================

%%------------------------------------------------------------------------------
%% @doc Checks if the provided side lengths can make up a triangle.<br />
%% If the side lengths A, B, and C are positive real numbers:
%% <ul>
%%  <li>A, B, C &gt; 0</li>
%%  <li>A &lt;= B &lt;= C</li>
%%  <li>A + B &gt; C</li>
%% </ul>
%% @end
%%------------------------------------------------------------------------------

-spec is_triangle(number(), number(), number()) -> true | false | no_return().

is_triangle(N1, N2, N3) when ?is_pos_number(N1), ?is_pos_number(N2), ?is_pos_number(N3) ->
    case lists:sort([N1, N2, N3]) of
        [A, B, C] when (A + B + 0) > C ->
            true;
        _ ->
            false
    end;
is_triangle(_, _, _) ->
    erlang:error(badarg).

%% ===================================================================
%%  Tests
%% ===================================================================

-ifdef(TEST).

integration_test_() ->
    {setup,
     fun()  -> _ = ok end,
     fun(_) -> _ = ok end,
     [
        % example
        % {"first integration test",
        %     [
        %         ?_assertMatch(ok, ok)),
        %         ?_assertMatch(ok, ok))
        %     ]
        % }
     ]
    }.

module_test_() ->

    % some setup here if needed
    % ok = ok,

    [
        {"valid input",
            [
                ?_assertMatch(true, ?MODULE:is_triangle(8.5, 8.5, 9)),
                ?_assertMatch(false, ?MODULE:is_triangle(1, 1.99999, 3))
            ]
        },
        {"invalid input",
            [
                ?_assertException(error, badarg, ?MODULE:is_triangle(0, 0.0, 0)),
                ?_assertException(error, badarg, ?MODULE:is_triangle("a", 8.1, 9))
            ]
        }
    ].

prop_test_() ->
    [
        {"is a triangle",
            [
                ?_assertMatch(true, eqc:quickcheck(eqc:numtests(1000, prop_is_triangle())))
            ]
        }
    ].

prop_is_triangle() ->
    eqc:forall({gen_pos_number(), gen_pos_number(), gen_pos_number()},
        fun({X, Y, Z}) ->
            if
                (X + Y) > Z andalso (X + Z) > Y andalso (Y + Z) > X ->
                    ?MODULE:is_triangle(X, Y, Z);
                true ->
                    not ?MODULE:is_triangle(X, Y, Z)
            end
        end).

gen_pos_number() ->
    eqc_gen:frequency([{1, gen_pos_nat()}, {1, gen_pos_real()}]).

gen_pos_real() ->
    eqc_gen:suchthat(eqc_gen:real(), fun(X) -> X > 0 end).

gen_pos_nat() ->
    eqc_gen:suchthat(eqc_gen:nat(), fun(X) -> X > 0 end).

-endif.
