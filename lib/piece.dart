enum  ChessPieceType{pawn,rook,knight,queen,king,bishop}
class ChessPiece{
      final ChessPieceType type;
      final bool isWhite;
      final String imagePath;
      ChessPiece({required this.isWhite,required this.type,required this.imagePath,});

}