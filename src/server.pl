% Modules needed for the server
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_json)).
:- use_module(library(http/json_convert)).
:- use_module(library(http/http_cors)).

% Modules needed for the API
:- use_module('game/end-of-game', []).
:- use_module('game/utils', []).
% :- use_module('ai/ai', []).

% Enable cross origin requests
:- set_setting(http:cors, [*]).

%%%%%% Create predicate to launch the server on the given port (on localhost)

server(Port) :- http_server(http_dispatch, [port(Port)]).

%%%%%% Define API endpoints

% Send the initial board as a json array
% Requirements: none
% URL Parameters: none
% JSON header: none
% Result: json arrray 10 * 10
%         - 0 : empty case
%         - -1: white token
%         - 1 : black token
:- http_handler('/api/board/initial', api_board_initial, []).

% Send the updated board after the given move is played
% Requirements: - the given move must be a valid one (see /api/play/validate)
%               - the given board must be a valid one (10*10 containing 0, -1 or 1 only)
% URL Parameters:
%   - player: the player playing the given move
%         - -1: white tokens player
%         - 1 : black tokens player
%   - movex: the x coordinate of the move (integer between 1 and 8)
%   - movey: the y coordinate of the move (integer between 1 and 8)
% JSON header: the current board as a json array
% Result: json arrray 10 * 10
%         - 0 : empty case
%         - -1: white token
%         - 1 : black token
:- http_handler('/api/board/update', api_board_update, []).

% Play one move as the given AI, and send back the updated board
% Requirements: the given board must be a valid one (10*10 containing 0, -1 or 1 only)
% URL Parameters:
%   - ai: the AI according to which the move will be played
%         - 0: totally random AI
%         - 1: random first correct move AI
%         - 2: basic AI (compute the best instant move)
%         - 3: min-max AI
%   - player: the player which the AI will play for
%         - -1: white tokens player
%         - 1 : black tokens player
% JSON header: the current board as a json array
% Result: json arrray 10 * 10
%         - 0 : empty case
%         - -1: white token
%         - 1 : black token
:- http_handler('/api/play', api_play, []).

% Return true if the given move can be played, or false otherwise (in a JSON file)
% Requirements: the given board must be a valid one (10*10 containing 0, -1 or 1 only)
% URL Parameters:
%   - player: the player which the AI will play for
%         - -1: white tokens player
%         - 1 : black tokens player
%   - movex: the x coordinate of the move (integer between 1 and 8)
%   - movey: the y coordinate of the move (integer between 1 and 8)
% JSON header: the current board as a json array
% Result: json object
% {
%   move: {
%     x: <movex>,
%     y: <movey>,
%   },
%   board: <the_given_board>,
%   playable: true | false
% }
:- http_handler('/api/play/validate', api_play_validate, []).

% Return true if the given player can play at least one move on the given board.
% Requirements: the given board must be a valid one (10*10 containing 0, -1 or 1 only)
% URL Parameters:
%   - player: the player which the AI will play for
%         - -1: white tokens player
%         - 1 : black tokens player
% JSON header: the current board as a json array
% Result: json object
% {
%   board: <the_given_board>,
%   playable: true | false
% }
:- http_handler('/api/play/able', api_play_able, []).


%%%%%% Define API calls' handlers

% /api/board/initial
initialBoard([
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
]).
api_board_initial(_) :-
    initialBoard(Board),
    prolog_to_json(Board, JsonBoard),
    cors_enable,
    reply_json_dict(JsonBoard).
    
% /api/board/update
% Requirements: - the given move must be a valid one (see /api/play/validate)
%               - the given board must be a valid one (10*10 containing 0, -1 or 1 only)
api_board_update(Request) :-
    http_parameters(Request, [
      player(Player, [integer, oneof([-1, 1])]),
      movex(X, [integer, between(1, 8)]),
      movey(Y, [integer, between(1, 8)])
    ]),
    http_read_json_dict(Request, JsonBoard),
    json_to_prolog(JsonBoard, Board),
    % TODO:
    format(user_output, "Board is ~p~n", [Board]),
    utils:updateBoard(Board, Player, X, Y, NextBoard),
    format(user_output, "NextBoard is ~p~n", [NextBoard]),
    % - make it work with 0s instead of _
    prolog_to_json(NextBoard, JsonBoard),
    %NextBoard = 'This API endpoint is not yet implemented',
    cors_enable,
    reply_json_dict(JsonBoard).
    %reply_json_dict(json([error=NextBoard])).
    
% /api/play
% Requirements: the given board must be a valid one (10*10 containing 0, -1 or 1 only)
api_play(Request) :-
    http_parameters(Request, [
      player(Player, [integer, oneof([-1, 1])]),
      ai(Ai, [integer, between(0, 3)])
    ]),
    http_read_json_dict(Request, JsonBoard),
    json_to_prolog(JsonBoard, Board),
    % TODO:
    % - ai:bestMove(Board, Ai, X, Y, Player),
    % - !,  % To prevent the case where several best moves are possible from happening
    % - utils:updateBoard(Board, Player, X, Y, NextBoard),
    % - prolog_to_json(NextBoard, JsonBoard),
    NextBoard = "This API endpoint is not yet implemented",
    cors_enable,
    % - reply_json_dict(JsonBoard).
    reply_json_dict(json([error=NextBoard])).
    
% /api/play/validate
% Requirements: the given board must be a valid one (10*10 containing 0, -1 or 1 only)
api_play_validate(Request) :-
    http_parameters(Request, [
      player(Player, [integer, oneof([-1, 1])]),
      movex(X, [integer, between(1, 8)]),
      movey(Y, [integer, between(1, 8)])
    ]),
    http_read_json_dict(Request, JsonBoard),
    json_to_prolog(JsonBoard, Board),
    % TODO:
    % - game:canBePlayed(Board, X, Y, Player),
    % - Playable = true,
    Result = "This API endpoint is not yet implemented",
    Playable = false,
    cors_enable,
    % - reply_json_dict(json([move=json([x=X, y=Y]), board=Board, playable=Playable])).
    reply_json_dict(json([error=Result, move=json([x=X, y=Y]), board=Board, playable=Playable])).
% In case the move can't be played
/* api_play_validate(Request) :-
    http_parameters(Request, [
      player(Player, [integer, oneof([-1, 1])]),
      movex(X, [integer, between(1, 8)]),
      movey(Y, [integer, between(1, 8)])
    ]),
    http_read_json_dict(Request, JsonBoard),
    json_to_prolog(JsonBoard, Board),
    Playable = false,
    cors_enable,
    reply_json_dict(json([move=json([x=X, y=Y]), board=Board, playable=Playable])). */

% /api/play/able
% Requirements: the given board must be a valid one (10*10 containing 0, -1 or 1 only)
api_play_able(Request) :-
    http_parameters(Request, [
      player(Player, [integer, oneof([-1, 1])])
    ]),
    http_read_json_dict(Request, JsonBoard),
    json_to_prolog(JsonBoard, Board),
    % TODO
    % - game:playerCanPlay(Board, Player),
    % - Playable = true,
    Result = "This API endpoint is not yet implemented",
    Playable = false,
    cors_enable,
    % - reply_json_dict(json([board=Board, playable=Playable])).
    reply_json_dict(json([error=Result, board=Board, playable=Playable])).
% In case the has no move remaining
/* api_play_validate(Request) :-
    http_parameters(Request, [
      player(Player, [integer, oneof([-1, 1])])
    ]),
    http_read_json_dict(Request, JsonBoard),
    json_to_prolog(JsonBoard, Board),
    Playable = false,
    cors_enable,
    reply_json_dict(json([board=Board, playable=Playable])). */
    
    
%%%%%% Launch the server on port 8000

:- server(8000).



%%%%%% Transform the board with 0s to a board usable by the rest of the code (with _)

%usable_board(ZeroedBoard, UsableBoard) :- .
    
    
usable_row([0 | []], [UsableHead | []]) :- UsableHead = _, !.
usable_row([ZeroedHead | []], [UsableHead | []]) :- UsableHead = ZeroedHead.
usable_row([0 | ZeroedTail], [UsableHead | UsableTail]) :- UsableHead = _, usable_row(ZeroedTail, UsableTail), !.
usable_row([ZeroedHead | ZeroedTail], [UsableHead | UsableTail]) :- UsableHead = ZeroedHead, usable_row(ZeroedTail, UsableTail).
    
usable_board([ZeroedHead | []], [UsableHead | []]) :- usable_row(ZeroedHead, UsableHead), !.
usable_board([ZeroedHead | ZeroedTail], [UsableHead | UsableTail]) :- usable_row(ZeroedHead, UsableHead), usable_board(ZeroedTail, UsableTail).
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    