:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_json)).
:- use_module(library(http/json_convert)).

% This predicate allows us to launch the server on the port given as parameter
server(Port) :- http_server(http_dispatch, [port(Port)]).

%%%%%%%%%%%%%%%%%%%%%%%%
% The basics !
% Add a basic route
:- http_handler(/, welcome, []).

% Add a basic request handler
welcome(_Request) :-
    format('Content-type: text/plain~n~n'),
    format('Hello World!~n').
    
%%%%%%%%%%%%%%%%%%%%%%%%
% Let's try to build an API endpoint,
% which send back the square number of the given X
square(X, Res) :- Res is X * X .
api_square(Request) :-
    http_parameters(Request, [number(Number, [number])]),
    square(Number, Res),
    reply_json(json([number=Number, square=Res])).
:- http_handler('/square', api_square, []).

%%%%%%%%%%%%%%%%%%%%%%%%
% And now, let's try to translate JSON to Prolog and vice versa
% First build a handler able to echo a json file
api_json_echo(Request) :-
    http_read_json_dict(Request, JsonIn),
    json_to_prolog(JsonIn, Object),
    format(user_output, "~p~n", [Object]),
    reply_json_dict(JsonIn).
:- http_handler('/json/echo', api_json_echo, []).
% Example with:
% curl -H "Content-Type: application/json" -X POST -d '{"Board":[{"id":0, "row":[{"id":0, "value":0}, {"id":1, "value":-1}]}]}' http://localhost:8000/json/echo

% And now, let's build an API endpoint which send a board as a json!
:- assert(testBoard([
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0,-1, 1, 0, 0, 0, 0],
    [0, 0, 0, 0, 1,-1, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
])).
api_json_board(_) :-
    testBoard(Board),
    prolog_to_json(Board, JsonBoard),
    reply_json_dict(JsonBoard).
:- http_handler('/json/board', api_json_board, []).

% To run the server on port 8000: server(8000).