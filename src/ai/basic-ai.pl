:- module('basic_ai', []).
:- use_module('../game/end-of-game', []).
:- use_module('utils_ai', []).


%testBoard(Board) :- 
%    Board =[
%    [_, _, _, _, _, _, _, _, _, _], 
%    [_, _, _, _, _, _, _, _, _, _], 
%    [_, _, _, _, _, _, _, _, _, _], 
%    [_, _, _, _, _, _, _, _, _, _], 
%    [_, _, _, _, -1, 1, _, _, _, _], 
%    [_, _, _, _, 1, -1, _, _, _, _], 
%    [_, _, _, _, _, _, _, _, _, _], 
%    [_, _, _, _, _, _, _, _, _, _], 
%    [_, _, _, _, _, _, _, _, _, _], 
%    [_, _, _, _, _, _, _, _, _, _]
%    ].


scoreCoefBoard(ScoreBoard) :- ScoreBoard =  [[1000 , -30 , 10 , 10 , 10 , 10 , 10 , 10 , -30 , 1000 ], 
                                            [-30   , -50 , -5 , -5 , -5 , -5 , -5 , -5  , -50 , -30  ], 
                                            [10    , -5  , 1  , 1  , 1  , 1  , 1  , 1   , -5  , 10   ], 
                                            [10    , -5  , 1  , 1  , 1  , 1  , 1  , 1   , -5  , 10   ], 
                                            [10    , -5  , 1  , 1  , 1  , 1  , 1  , 1   , -5  , 10   ], 
                                            [10    , -5  , 1  , 1  , 1  , 1  , 1  , 1   , -5  , 10   ], 
                                            [10    , -5  , 1  , 1  , 1  , 1  , 1  , 1   , -5  , 10   ], 
                                            [10    , -5  , 1  , 1  , 1  , 1  , 1  , 1   , -5  , 10   ], 
                                            [-30   , -50 , -5 , -5 , -5 , -5 , -5 , -5  , -50 , -30  ], 
                                            [1000  , -30 , 10 , 10 , 10 , 10 , 10 , 10 , -30 , 1000 ]].

getScoreBoard(Board, Score) :- getScoreBoard(Board, Score, 1).
getScoreBoard(Board, Score, Player) :- getScoreBoard(Board, PlayerIndependantScore, 1, 1), Score is PlayerIndependantScore*Player.

getScoreBoard(_, Score, 8, 9) :- Score is 0, !.
%% if we try to go too far on Y increment X
getScoreBoard(Board, Score, LastX, 9) :- X is LastX+1, getScoreBoard(Board, Score, X, 1), !.
%% if the case is unset, score don't change
getScoreBoard(Board, Score, LastX, LastY) :- utils:getVal(Board, LastX, LastY, Case), var(Case), Y is LastY+1, getScoreBoard(Board, Score, LastX, Y), !.
%% else add the case value to the currant score
getScoreBoard(Board, Score, LastX, LastY) :- utils:getVal(Board, LastX, LastY, Case), Y is LastY+1, getScoreBoard(Board, OldScore, LastX, Y), Score is OldScore+Case, !.

bestMove(Board, X, Y, Player) :- utils_ai:possibleMoves(Board, Player, PossibleMoves), foundBestMove(Board, PossibleMoves, -99999, X, Y, Player), !.

%foundBestMove(+Board, +MoveList, +BestScore, -BestX, -BestY, +Player)
foundBestMove(_, [], _, _, _, _) :- format(user_output, 'end ai2~n', []), !.

foundBestMove(Board, [Move|Tail], BestScore, BestX, BestY, Player) :-
    utils_ai:getXYMove(Move, X, Y), 
    utils:updateBoard(Board, Player, X, Y, NewBoard), 
    getScoreBoard(NewBoard, Score, Player), 
    Score > BestScore, 
    foundBestMove(Board, Tail, Score, NewBestX, NewBestY, Player), 
    ( % if a better score is found set return var with it else use the current one
        ( 
            var(NewBestX), 
            var(NewBestY), 
            BestX is X, 
            BestY is Y
        )
        ;
        ( 
            BestX is NewBestX,
            BestY is NewBestY
        )
    ), 
    !.

foundBestMove(Board, [_|Tail], BestScore, BestX, BestY, Player) :- 
    foundBestMove(Board, Tail, BestScore, BestX, BestY, Player), 
    !.
    


    
    
    
    
    
    
    
    
