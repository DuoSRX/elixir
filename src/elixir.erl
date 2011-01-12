-module(elixir).
-export([eval/1, eval/2, throw_elixir/1, throw_erlang/1]).

% Evaluates a string
eval(String) -> eval(String, []).

eval(String, Binding) ->
  {value, Value, NewBinding} = erl_eval:exprs(parse(String), Binding),
  {Value, NewBinding}.

% Temporary to aid debugging
throw_elixir(String) ->
  erlang:error(io:format("~p~n", [parse(String)])).

% Temporary to aid debugging
throw_erlang(String) ->
  {ok, Tokens, _} = erl_scan:string(String),
  {ok, [Form]} = erl_parse:parse_exprs(Tokens),
  erlang:error(io:format("~p~n", [Form])).

% Parse string and transform tree to Erlang Abstract Form format
parse(String) ->
	{ok, Tokens, _} = elixir_lexer:string(String),
	{ok, Forms} = elixir_parser:parse(Tokens),
  Transform = fun(X, Acc) -> [transform(X, [], [])|Acc] end,
  lists:foldr(Transform, [], Forms).

% TODO transformations should contain the filename

% A transformation receives a node with a Filename and a Scope
% and transforms it to Erlang Abstract Form.
transform({match, Line, Left, Right}, F, S) ->
  {match, Line, transform(Left, F, S), transform(Right, F, S)};

transform({binary_op, Line, Op, Left, Right}, F, S) ->
  {op, Line, Op, transform(Left, F, S), transform(Right, F, S)};

transform({unary_op, Line, Op, Right}, F, S) ->
  {op, Line, Op, transform(Right, F, S)};

transform({'fun', Line, Clauses}, F, S) ->
  {'fun', Line, transform(Clauses, F, S)};

transform({clauses, Clauses}, F, S) ->
  {clauses, [transform(Clause, F, S) || Clause <- Clauses]};

transform({clause, Line, Args, Guards, Exprs}, F, S) ->
  {clause, Line, Args, Guards, [transform(Expr, F, S) || Expr <- Exprs]};

transform({call, Line, Vars, Args }, F, S) ->
  {call, Line, Vars, [transform(Arg, F, S) || Arg <- Args]};

transform({module, Line, Name, Exprs}, F, S) ->
  Scope = elixir_module:scope_for(Name),
  Body = [transform(Expr, F, Scope) || Expr <- Exprs],
  elixir_module:compile(Line, Name, Body, Scope),
  {nil, Line};

% TODO This cannot be tested, because in theory the parser will never
% allow us to have this behavior. In any case, we will need to wrap
% it in the future by Elixir exception handling.
transform({method, Line, Name, Arity, Clauses}, F, []) ->
  erlang:error("Method definition outside the scope.");
  
transform({method, Line, Name, Arity, Clauses}, F, S) ->
  TClauses = [transform(Clause, F, S) || Clause <- Clauses],
  Method = {function, Line, Name, Arity, TClauses},
  elixir_module:store_method(S, Method);

% Match all other expressions
transform(Expr, F, S) -> Expr.