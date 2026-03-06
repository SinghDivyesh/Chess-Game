import 'package:chess/components/square.dart';
import 'package:chess/helper/helping_methods.dart';
import 'package:chess/piece.dart';
import 'package:chess/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'components/dead_piece.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  // 2 Dimensional list presenting gameboard
  late List<List<ChessPiece?>> board;
  //the currently selected piece on game board
  // if not selected then it will be null
  ChessPiece? selectedPiece;
  //the row index of selected piece
  //default value -1 indicate the currenty no piece is selected
  int selectedRow = -1;
  //the col index of selected piece
  //default value -1 indicate the currenty no piece is selected
  int selectedCol = -1;
  //list a valid move  for currently selected piece
  //each move is  represented as a list with 2 element row and col
  List<List<int>> validMoves = [];
  //list of white pieces that have been take by black pieces
  List<ChessPiece> whitePiecesTaken = [];
  //list of black pieces that have been take by  white pieces
  List<ChessPiece> blackPiecesTaken = [];
  // a boolean to indicate whose turn
  bool isWhiteTurn = true;
  // keep track of both kings to check later that king is in check or not
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeBoard();
  }

  //initialize Board
  void _initializeBoard() {
    List<List<ChessPiece?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));
    // checking the functions of each piece
    // newBoard[3][3]= ChessPiece(
    //   isWhite: true,
    //   type: ChessPieceType.queen,
    //   imagePath: 'assets/piece/queen.png',
    // );
    //place pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
        isWhite: false,
        type: ChessPieceType.pawn,
        imagePath: 'assets/piece/pawn.png',
      );
      newBoard[6][i] = ChessPiece(
        isWhite: true,
        type: ChessPieceType.pawn,
        imagePath: 'assets/piece/pawn.png',
      );
    }

    //place rooks
    newBoard[0][0] = ChessPiece(
      isWhite: false,
      type: ChessPieceType.rook,
      imagePath: 'assets/piece/rook.png',
    );
    newBoard[0][7] = ChessPiece(
      isWhite: false,
      type: ChessPieceType.rook,
      imagePath: 'assets/piece/rook.png',
    );
    newBoard[7][0] = ChessPiece(
      isWhite: true,
      type: ChessPieceType.rook,
      imagePath: 'assets/piece/rook.png',
    );
    newBoard[7][7] = ChessPiece(
      isWhite: true,
      type: ChessPieceType.rook,
      imagePath: 'assets/piece/rook.png',
    );
    //place knight
    newBoard[0][1] = ChessPiece(
      isWhite: false,
      type: ChessPieceType.knight,
      imagePath: 'assets/piece/knight.png',
    );
    newBoard[0][6] = ChessPiece(
      isWhite: false,
      type: ChessPieceType.knight,
      imagePath: 'assets/piece/knight.png',
    );
    newBoard[7][1] = ChessPiece(
      isWhite: true,
      type: ChessPieceType.knight,
      imagePath: 'assets/piece/knight.png',
    );
    newBoard[7][6] = ChessPiece(
      isWhite: true,
      type: ChessPieceType.knight,
      imagePath: 'assets/piece/knight.png',
    );
    //place king
    newBoard[0][4] = ChessPiece(
      isWhite: false,
      type: ChessPieceType.king,
      imagePath: 'assets/piece/crown.png',
    );
    newBoard[7][4] = ChessPiece(
      isWhite: true,
      type: ChessPieceType.king,
      imagePath: 'assets/piece/crown.png',
    );
    //place queen
    newBoard[0][3] = ChessPiece(
      isWhite: false,
      type: ChessPieceType.queen,
      imagePath: 'assets/piece/queen.png',
    );
    newBoard[7][3] = ChessPiece(
      isWhite: true,
      type: ChessPieceType.queen,
      imagePath: 'assets/piece/queen.png',
    );
    //place bishops
    newBoard[0][2] = ChessPiece(
      isWhite: false,
      type: ChessPieceType.bishop,
      imagePath: 'assets/piece/bishop.png',
    );
    newBoard[0][5] = ChessPiece(
      isWhite: false,
      type: ChessPieceType.bishop,
      imagePath: 'assets/piece/bishop.png',
    );
    newBoard[7][2] = ChessPiece(
      isWhite: true,
      type: ChessPieceType.bishop,
      imagePath: 'assets/piece/bishop.png',
    );
    newBoard[7][5] = ChessPiece(
      isWhite: true,
      type: ChessPieceType.bishop,
      imagePath: 'assets/piece/bishop.png',
    );
    board = newBoard;
  }

  //user selected piece
  void pieceSelected(int row, int col) {
    setState(() {
      //selected piece if there is piece in that position
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      }
      // there is a piece already selected but user can select another one of thier piecec
      else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      } else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }
      //if a piece is selected calculate it's valid moves
      validMoves = calculateRealValidMoves(
          selectedRow, selectedCol, selectedPiece, true);
    });
  }

//calculate raw valid moves
  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];
    if (piece == null) {
      return [];
    }
    //different moves based on their colors
    int direction = piece.isWhite ? -1 : 1;
    switch (piece.type) {
      case ChessPieceType.pawn:
        // pawn can move forward if square is not occupied
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }
        // pawn can move 2 step forword if they are in initial stage
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }
        // pawn can kill diagonally
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }
        break;
      case ChessPieceType.rook:
        // horizontal and vertical directions
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1]
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); //kill
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.knight:
        // all eight possible moves
        var KnightMoves = [
          [-2, -1],
          [-2, 1],
          [-1, -2],
          [-1, 2],
          [1, -2],
          [1, 2],
          [2, -1],
          [2, 1],
        ];
        for (var move in KnightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
      case ChessPieceType.bishop:
        var directions = [
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1],
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); //kill
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.queen:
        //all eight directions :up ,down,left,right,4 diagonal
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1],
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); //kill
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.king:
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1],
        ];
        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); //kill
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
    }
    return candidateMoves;
  }

  // calculate real valid moves
  List<List<int>> calculateRealValidMoves(int row, int col, ChessPiece? piece, bool checkSimulation) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);
    // after  generating all candidate moves, filter out that any would result in check
    if (checkSimulation) {
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];
        if (simulatedMoveIsSafe(piece!, row, col, endRow, endCol)) {
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = candidateMoves;
    }
    return realValidMoves;
  }

  void movePiece(int newRow, int newCol) {
    // if the new spot has an enemy
    if (board[newRow][newCol] != null) {
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
    }
    // check piece being moved in  king
    if (selectedPiece!.type == ChessPieceType.king) {
      //update appropriate king pos
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }
    //move the piece and clear old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;
    //==========================================================================
    // Check for pawn promotion
    if (selectedPiece!.type == ChessPieceType.pawn &&
        ((selectedPiece!.isWhite && newRow == 0) ||
            (!selectedPiece!.isWhite && newRow == 7))) {
      // Show promotion dialog
      showPromotionDialog(newRow, newCol);
      return; // Return to prevent further checks until promotion is complete
    }
    //=====================================================================================
    //see if any kings are in check
    if (isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }
    //clear the selection
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });
    // check if its checkmate
    if (isItCheckMate(!isWhiteTurn)) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          alignment: Alignment.bottomCenter,
          backgroundColor: Colors.grey,
          title: Text(
            "CHECK MATE!!",
            style: myNewFont,
          ),
          actions: [
            // play again
            TextButton(
              onPressed: resetGame,
              child: Text(
                "play again",
                style: myNewFont,
              ),
            ),
          ],
        ),
      );
    }
    // change turn
    isWhiteTurn = !isWhiteTurn;
  }
  //show pawn promotion dialoge
  void showPromotionDialog(int row, int col) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Promote Pawn to:",style: myNewFont.copyWith(fontSize: 12),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text("Queen",style: myNewFont,),
                onTap: () {
                  promotePawn(row, col, ChessPieceType.queen);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text("Rook",style: myNewFont,),
                onTap: () {
                  promotePawn(row, col, ChessPieceType.rook);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text("Bishop",style: myNewFont,),
                onTap: () {
                  promotePawn(row, col, ChessPieceType.bishop);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text("Knight",style: myNewFont,),
                onTap: () {
                  promotePawn(row, col, ChessPieceType.knight);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
  //pawn promote function
  void promotePawn(int row, int col, ChessPieceType newType) {
    setState(() {
      board[row][col] = ChessPiece(
        type: newType,
        isWhite: selectedPiece!.isWhite,
        imagePath: getImagePathForType(newType, selectedPiece!.isWhite), // Update image path
      );
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });
  }
  // get image path for pawn promotion
  String getImagePathForType(ChessPieceType type, bool isWhite) {
    String baseImagePath;
    switch (type) {case ChessPieceType.queen:
      baseImagePath = 'assets/piece/queen.png';
      break;
      case ChessPieceType.rook:
        baseImagePath = 'assets/piece/rook.png';
        break;
      case ChessPieceType.bishop:baseImagePath = 'assets/piece/bishop.png';
      break;
      case ChessPieceType.knight:
        baseImagePath = 'assets/piece/knight.png';
        break;
      default:
        return ''; // Handle other cases or throw an error
    }
    return baseImagePath;
  }

  // is king in check?
  bool isKingInCheck(bool isWhiteKing) {
    // get the position of king
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;
    //check if any king can attack the kings
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // skip empty square and piece of the same color as the king
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }
        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], false);
        // check kings position is in this pieces's valid moves
        if (pieceValidMoves.any((move) =>
            move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }
    return false;
  }

  // simulate a future  move to  see if its safe (doesnt put your king under attack)
  bool simulatedMoveIsSafe(ChessPiece piece, int startRow, int startCol, int endRow, int endCol) {
    // current board state
    ChessPiece? originalDestinationPiece = board[endRow][endCol];
    //if the piece is the king, save its current position and update to the new one
    List<int>? originalKingPosition;
    if (piece.type == ChessPieceType.king) {
      originalKingPosition =
          piece.isWhite ? whiteKingPosition : blackKingPosition;
      // update the king  position
      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }
    //simulate the move
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    //check if our own king is under attack
    bool kingInCheck = isKingInCheck(piece.isWhite);
    // restore board to original  state
    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;

    // if the piece was king restore its original position
    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }
    return !kingInCheck;
  }

  bool isItCheckMate(bool isWhiteKing) {
    // if king is not is check then its not checkmate
    if (!isKingInCheck(isWhiteKing)) {
      return false;
    }
    //if there is atleast one legal move any for any  of the players piece then its not checkmate
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // skip if its empty square and piece of other color
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }
        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], true);
        // if this piece  has any valid moves then its not check mate
        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }
    // if none of the above condition are met  then there are no  legal move left to make
    // its check mate!
    return true;
  }

  // reset game to new game
  void resetGame() {
    Navigator.pop(context);
    _initializeBoard();
    checkStatus = false;
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
    isWhiteTurn = true;
    setState(() {});
  }

  static var myNewFontWhite = GoogleFonts.pressStart2p(
      textStyle: TextStyle(
    color: Colors.white,
    letterSpacing: 3,
  ));
  static var myNewFont = GoogleFonts.pressStart2p(
      textStyle: TextStyle(color: Colors.black, letterSpacing: 3));
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Block default pop behavior
      onPopInvoked: (didPop) async {
        if (!didPop) {
          bool? shouldQuit = await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                "Exit Game",
                style: myNewFont,
              ),
              content: Text(
                "Do you really want to quit the game?",
                style: myNewFont,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    "Cancel",
                    style: myNewFont,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    "Yes",
                    style: myNewFont,
                  ),
                ),
              ],
            ),
          );

          if (shouldQuit == true) {
            SystemNavigator.pop(); // Close app
          }
        }
      },

      child: Scaffold(
        backgroundColor: Colors.grey[500],
        body: Column(
          children: [
            Expanded(
                child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: whitePiecesTaken.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context, index) => DeadPiece(
                imagepath: whitePiecesTaken[index].imagePath,
                isWhite: true,
              ),
            )),
            // game status
            Text(
              checkStatus ? "Check" : " ",
              style: myNewFontWhite,
            ),
            Expanded(
              flex: 3,
              child: GridView.builder(
                  itemCount: 64,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8),
                  itemBuilder: (context, index) {
                    // get row and col of  position of   this square
                    int row = index ~/ 8;
                    int col = index % 8;
                    //check is square is selected
                    bool isSelected = selectedRow == row && selectedCol == col;
                    //check if a square is valid move
                    bool isValidMove = false;
                    for (var position in validMoves) {
                      //compare row and col
                      if (position[0] == row && position[1] == col) {
                        isValidMove = true;
                      }
                    }
                    return Square(
                      isWhite: isWhite(index),
                      piece: board[row][col],
                      isSelected: isSelected,
                      isValidMove: isValidMove,
                      onTap: () => pieceSelected(row, col),
                    );
                  }),
            ),
            Expanded(
                child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: blackPiecesTaken.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context, index) => DeadPiece(
                imagepath: blackPiecesTaken[index].imagePath,
                isWhite: false,
              ),
            )),
          ],
        ),
      ),
    );
  }
}
