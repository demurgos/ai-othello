
board(Board) :- Board =  [[ _, _, _, _, _, _, _, _, _, _],
                          [ _, 1, 1, 1, 1, 1, 1, 1, 1, _],
                          [ _, _, _, _, _, _, _, _, _, _],
                          [ _,-1,-1,-1,-1,-1,-1,-1,-1, _],
                          [ _, _, _, _, _, _, _, _, _, _],
                          [ _, _, _, _, _, _, _, _, _, _],
                          [ _, _, _, _, _, _, _, _, _, _],
                          [ _, _,-1, _, _, _, _,-1, _, _],
                          [ _, _, _, _, _, _, _, _, _, _],
                          [ _, _, _, _, _, _, _, _, _, _]].


getVal(X, Y, Val)  :- board(Board),  nth0(X, Board, Column), nth0(Y, Column, Val).

displayCell(Val) :- var(Val), write('   |'), !.
displayCell(-1) :- write(' x |'), !.
displayCell(1) :- write(' o |'), !.

displayCell(IndexRow, IndexColumn) :- getVal(IndexRow, IndexColumn, Val), displayCell(Val).

displayRow(Y):- 
    write('|'),
    displayCell(1, Y),
    displayCell(2, Y),
    displayCell(3, Y),
    displayCell(4, Y),
    displayCell(5, Y),
    displayCell(6, Y),
    displayCell(7, Y),
    displayCell(8, Y),
    writeln(''),
 	writeln('---------------------------------').

displayBoard:- 
	writeln('---------------------------------'),
    displayRow(1),
    displayRow(2),
    displayRow(3),
    displayRow(4),
    displayRow(5),
    displayRow(6),
    displayRow(7),
    displayRow(8),
    writeln('').
    