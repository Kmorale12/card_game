import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState(),
      child: MaterialApp(
        home: CardMatchingGame(),
      ),
    );
  }
}

class CardModel { //This class represents the card model, essentially the front, back, and the state of the card
  final String front;
  final String back; 
  bool isFaceUp;
  bool isMatched;

  CardModel({required this.front, required this.back, this.isFaceUp = false, this.isMatched = false});
}

class GameState extends ChangeNotifier {
  List<CardModel> cards = [];
  List<CardModel> flippedCards = []; // List of cards that are currently flipped
  int matchedPairs = 0;
  int attempts = 0;

  GameState() {
    _initializeCards(); // Initialize the cards when the game starts with 8 distinct pairs
  }

  void _initializeCards() { //shuffle the cards and assign the front and back of the cards
    List<String> numbers = List.generate(8, (index) => (index + 1).toString());
    List<String> cardFaces = [...numbers, ...numbers];
    cardFaces.shuffle(Random());

    cards = cardFaces.map((number) => CardModel(front: number, back: 'B')).toList();
  }

  void flipCard(CardModel card) {
    if (card.isFaceUp || card.isMatched) return;

    card.isFaceUp = true; // Flip the card
    flippedCards.add(card);

    if (flippedCards.length == 2) { // Check if two cards are flipped
      attempts++;
      if (flippedCards[0].front == flippedCards[1].front) {
        flippedCards[0].isMatched = true;
        flippedCards[1].isMatched = true;
        matchedPairs++;
        flippedCards.clear();
      } else {
        Future.delayed(Duration(milliseconds: 500), () {  // Delay the flip back of the cards
          flippedCards[0].isFaceUp = false;
          flippedCards[1].isFaceUp = false;
          flippedCards.clear();
          notifyListeners();
        });
      }
    }
    notifyListeners();
  }

  void resetGame() { // Resetz the game
    matchedPairs = 0;
    attempts = 0;
    flippedCards.clear();
    _initializeCards();
    notifyListeners();
  }
}

class CardMatchingGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Card Matching Game')),
      backgroundColor: Colors.green[800], // Pool table green background
      body: Column(
        children: [
          Expanded(
            child: GridView.builder( // Grid view to display the cards
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.7, 
              ),
              padding: const EdgeInsets.all(16.0),
              itemCount: gameState.cards.length,
              itemBuilder: (context, index) {
                final card = gameState.cards[index];
                return GestureDetector(
                  onTap: () => gameState.flipCard(card),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: card.isFaceUp ? Colors.white : Colors.blue,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Center( // Center the text in the card
                      child: Text(
                        card.isFaceUp ? card.front : '',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red, 
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Matched Pairs: ${gameState.matchedPairs}', // Display the number of matched pairs and attempts
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                Text(
                  'Attempts: ${gameState.attempts}',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => gameState.resetGame(), // Reset the game
                  child: Text('Restart Game'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}