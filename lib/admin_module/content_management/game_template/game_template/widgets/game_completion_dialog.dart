import 'package:flutter/material.dart';

class GameCompletionDialog extends StatelessWidget {
  final int points;
  final int stars;
  final String subject;
  final int minutes;
  final VoidCallback onTryAgain;
  final VoidCallback onContinue;

  const GameCompletionDialog({
    Key? key,
    required this.points,
    required this.stars,
    required this.subject,
    required this.minutes,
    required this.onTryAgain,
    required this.onContinue,
  }) : super(key: key);
  
  // Check if the subject is Bahasa Malaysia
  bool get isBahasaMalaysia => subject.contains('Bahasa Malaysia');

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.indigo.shade200,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.videogame_asset, color: Colors.indigo, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    isBahasaMalaysia ? 'Aktiviti Selesai!' : 'Activity Completed!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Icon(
                  Icons.star,
                  color: index < stars ? Colors.amber : Colors.grey.shade300,
                  size: 36,
                );
              }),
            ),
            const SizedBox(height: 10),
            
            // Feedback text
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber),
              ),
              child: Text(
                isBahasaMalaysia 
                  ? 'Bagus sekali! Anda memperoleh $stars bintang!' 
                  : 'Excellent job! You earned $stars stars!',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Stats
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  // Points
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        const SizedBox(width: 10),
                        Text(
                          isBahasaMalaysia ? 'Mata Diperoleh' : 'Points Earned', 
                          style: const TextStyle(fontSize: 16)
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            '$points',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Time
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.blue),
                        const SizedBox(width: 10),
                        Text(
                          isBahasaMalaysia ? 'Masa Belajar' : 'Study Time', 
                          style: const TextStyle(fontSize: 16)
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            isBahasaMalaysia ? '$minutes minit' : '$minutes min',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Subject
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.book, color: Colors.green),
                        const SizedBox(width: 10),
                        Text(
                          isBahasaMalaysia ? 'Subjek' : 'Subject', 
                          style: const TextStyle(fontSize: 16)
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            subject,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: Text(isBahasaMalaysia ? 'Cuba Lagi' : 'Try Again'),
                  onPressed: onTryAgain,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(isBahasaMalaysia ? 'Teruskan' : 'Continue'),
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
