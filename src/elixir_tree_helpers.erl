-module(elixir_tree_helpers).
-export([abstract_syntax/1, build_bin/2, build_list/4, build_list/5,
  build_method_call/4, build_simple_list/2,
  build_var_name/2, convert_to_boolean/3]).
-include("elixir.hrl").

abstract_syntax(Tree) ->
  erl_syntax:revert(erl_syntax:abstract(Tree)).

% Build a list transforming each expression and accumulating
% vars in one pass. It uses tail-recursive form.
%
% It receives a function to transform each expression given
% in Exprs, a Line used to build the List and the variables
% scope V is passed down item by item.
%
% The function needs to return a tuple where the first element
% is an erlang abstract form and the second is the new variables
% list.
build_list(Fun, Exprs, Line, S) ->
  build_list(Fun, Exprs, Line, S, {nil, Line}).

build_list(Fun, Exprs, Line, S, Tail) ->
  build_list_each(Fun, lists:reverse(Exprs), Line, S, Tail).

build_list_each(Fun, [], Line, S, Acc) ->
  { Acc, S };

build_list_each(Fun, [H|T], Line, S, Acc) ->
  { Expr, NS } = Fun(H, S),
  build_list_each(Fun, T, Line, NS, { cons, Line, Expr, Acc }).

% Builds a simple list, without transformation, just by generating the cons-cell.
build_simple_list(Line, Args) ->
  { List, [] } = build_list(fun(X,Y) -> {X,Y} end, Args, Line, []),
  List.

% Build binaries
build_bin(Line, Exprs) ->
  Transformer = fun (X) -> { bin_element, Line, X, default, default } end,
  { bin, Line, lists:map(Transformer, Exprs) }.

build_method_call(Name, Line, Args, Expr) ->
  FArgs = build_simple_list(Line, Args),
  ?ELIXIR_WRAP_CALL(Line, elixir_dispatch, dispatch, [Expr, {atom, Line, Name}, FArgs]).

% Builds a variable name.
build_var_name(Line, #elixir_scope{counter=Counter} = S) ->
  NS = S#elixir_scope{counter=Counter+1},
  Var = { var, Line, ?ELIXIR_ATOM_CONCAT(["X", Counter]) },
  { Var, NS }.

% Convert the given expression to a boolean value: true or false.
% Assumes the given expressions was already transformed.
convert_to_boolean(Line, Expr, Bool) ->
  Any   = [{var, Line, '_'}],
  False = [{atom,Line,false}],
  Nil   = [{atom,Line,nil}],

  FalseResult = [{atom,Line,not Bool}],
  TrueResult  = [{atom,Line,Bool}],

  { 'case', Line, Expr, [
    { clause, Line, False, [], FalseResult },
    { clause, Line, Nil, [], FalseResult },
    { clause, Line, Any, [], TrueResult }
  ] }.