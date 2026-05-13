// ignore_for_file: avoid_print
import 'dart:io';
import 'package:image/image.dart';

void main() async {
  final moods = ['rad', 'happy', 'meh', 'sad', 'awful', 'angry'];
  
  for (final mood in moods) {
    final inputFile = File('assets/images/moods/$mood.png');
    final outputFile = File('assets/images/moods/${mood}_v3.png');
    
    if (!await inputFile.exists()) {
      print('File not found: ${inputFile.path}');
      continue;
    }

    try {
      final bytes = await inputFile.readAsBytes();
      final image = decodePng(bytes);
      
      if (image == null) {
        print('Could not decode ${inputFile.path}');
        continue;
      }
      
      // Get background color from (0,0)
      final bg = image.getPixel(0, 0);
      final bgR = bg.r;
      final bgG = bg.g;
      final bgB = bg.b;

      print('Processing $mood (BG: $bgR,$bgG,$bgB)...');

      // Process image
      for (var pixel in image) {
        // Distance from background color
        final dist = (pixel.r - bgR).abs() + (pixel.g - bgG).abs() + (pixel.b - bgB).abs();
        
        // Also check for pure white/near white which is common in "transparent" renders that aren't transparent
        final isWhite = pixel.r > 245 && pixel.g > 245 && pixel.b > 245;
        
        if (dist < 40 || isWhite) {
          pixel.a = 0; // Make transparent
        }
      }

      await outputFile.writeAsBytes(encodePng(image));
      print('Saved ${outputFile.path}');
      
    } catch (e) {
      print('Error processing $mood: $e');
    }
  }
}
