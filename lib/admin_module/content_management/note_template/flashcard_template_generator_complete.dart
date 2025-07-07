import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../models/note_content_element.dart';
import '../../../models/flashcard_element.dart';

/// FlashcardTemplateGenerator is responsible for generating flashcard content
/// based on subject, chapter, age, and language.
/// 
/// It supports the following subjects and chapters:
/// - Bahasa Malaysia: Huruf & Kata Asas, Perkataan Mudah
/// - English: Alphabet & Phonics, Sight Words
/// - Math: Counting 1-10, Shapes & Patterns
/// - Science: Five Senses, Living vs Non-living Things
/// - Social & Emotional Learning: Emotions & Expressions, Sharing & Cooperation
/// - Art & Craft: Color Exploration & Mixing, Simple Lines & Patterns
/// - Physical Development: Gross Motor Skills, Fine Motor Skills
/// - Jawi: Pengenalan Huruf Jawi, Penulisan Jawi Mudah
/// - Iqraa (Arabic): Huruf Hijaiyah, Bacaan Iqraa Asas
class FlashcardTemplateGenerator {
  /// Convert a list of flashcard maps to a JSON string
  static String toJson(List<Map<String, dynamic>> flashcards) {
    return jsonEncode(flashcards);
  }
  
  /// Generate flashcard elements for the given subject, chapter, age, and language
  static List<FlashcardElement> generateFlashcardElements({
    required String subject,
    required String chapter,
    required int age,
    required String language,
  }) {
    // Get the raw flashcard data
    final flashcardData = generateFlashcards(
      subject: subject,
      chapter: chapter,
      age: age,
      language: language,
      count: _getCardCountForAge(age),
    );
    
    final List<FlashcardElement> flashcardElements = [];
    
    for (var data in flashcardData) {
      // Create descriptions map with age-appropriate descriptions
      final Map<int, String> descriptions = {};
      
      // Get the base description from the data
      final baseDescription = data['description'] as String;
      
      // Create age-appropriate descriptions for ages 4, 5, and 6
      descriptions[4] = _createSimplifiedDescription(baseDescription, data['title'] as String);
      descriptions[5] = baseDescription; // Use the original description for age 5
      descriptions[6] = _createEnhancedDescription(baseDescription, data['title'] as String);
      
      // Debug print the descriptions
      print('Flashcard ${data['title']} descriptions: $descriptions');
      
      // Create FlashcardElement
      flashcardElements.add(FlashcardElement(
        id: const Uuid().v4(),
        position: flashcardElements.length,
        createdAt: Timestamp.now(),
        title: data['title'] as String,
        letter: data['letter'] as String? ?? _generateLetterFromTitle(data['title'] as String),
        imageAsset: data['image_asset'] as String? ?? _getImageAssetPath(subject, data['title'] as String),
        descriptions: descriptions,
        metadata: {
          'subject': subject,
          'chapter': chapter,
          'language': language,
        },
      ));
    }
    
    return flashcardElements;
  }
  
  // Helper method to generate a letter from the title
  static String _generateLetterFromTitle(String title) {
    if (title.isEmpty) return '';
    final firstLetter = title.substring(0, 1).toUpperCase();
    final secondLetter = title.substring(0, 1).toLowerCase();
    return '$firstLetter$secondLetter';
  }
  
  /// Create a simplified description for younger children (age 4)
  static String _createSimplifiedDescription(String baseDescription, String title) {
    // For age 4, create a very simple description - just the title
    switch (title.toLowerCase()) {
      // Malay letters simplified descriptions
      case 'ayam':
        return 'Ayam';
      case 'bola':
        return 'Bola';
      case 'cacing':
        return 'Cacing';
      case 'durian':
        return 'Durian';
      case 'epal':
        return 'Epal';
      case 'foto':
        return 'Foto';
      case 'gajah':
        return 'Gajah';
      case 'harimau':
        return 'Harimau';
      case 'ikan':
        return 'Ikan';
      case 'jeruk':
        return 'Jeruk';
      case 'kucing':
        return 'Kucing';
      case 'lampu':
        return 'Lampu';
      case 'meja':
        return 'Meja';
      case 'nanas':
        return 'Nanas';
      case 'orang':
        return 'Orang';
      case 'pokok':
        return 'Pokok';
        
      // Malay simple words simplified descriptions
      case 'saya':
        return 'Saya';
      case 'kamu':
        return 'Kamu';
      case 'makan':
        return 'Makan';
      case 'minum':
        return 'Minum';
      case 'tidur':
        return 'Tidur';
      case 'baca':
        return 'Baca';
      case 'tulis':
        return 'Tulis';
      case 'lari':
        return 'Lari';
      case 'main':
        return 'Main';
      case 'suka':
        return 'Suka';

    // Jawi Letters simplified descriptions
    case 'alif':
      return 'ا';
    case 'ba':
      return 'ب';
    case 'ta':
      return 'ت';
    case 'tsa':
      return 'ث';
    case 'jim':
      return 'ج';
    case 'ha':
      return 'ح';
    case 'kha':
      return 'خ';
    case 'dal':
      return 'د';
    case 'dzal':
      return 'ذ';
    case 'ra':
      return 'ر';

    // Jawi Simple Writing simplified descriptions
    case 'saya':
      return 'سايا';
    case 'kamu':
      return 'كامو';
    case 'dia':
      return 'دي';
    case 'kita':
      return 'كيت';
    case 'ibu':
      return 'ايبو';
    case 'bapa':
      return 'باڤ';
    case 'makan':
      return 'ماكن';
    case 'minum':
      return 'مينوم';
    case 'sekolah':
      return 'سكوله';
    case 'rumah':
      return 'روماه';

    // Basic Iqraa Reading simplified descriptions
    case 'alif fathah':
      return 'اَ = a';
    case 'ba fathah':
      return 'بَ = ba';
    case 'ta fathah':
      return 'تَ = ta';
    case 'tha fathah':
      return 'ثَ = tsa';
    case 'jim fathah':
      return 'جَ = ja';
    case 'ha fathah':
      return 'حَ = ha';
    case 'kha fathah':
      return 'خَ = kha';
    case 'dal fathah':
      return 'دَ = da';
    case 'dzal fathah':
      return 'ذَ = dza';
    case 'ra fathah':
      return 'رَ = ra';

      // English sight words simplified descriptions
      case 'the':
        return 'The';
      case 'and':
        return 'And';
      case 'a':
        return 'A';
      case 'to':
        return 'To';
      case 'in':
        return 'In';
      case 'is':
        return 'Is';
      case 'you':
        return 'You';
      case 'that':
        return 'That';
      case 'it':
        return 'It';
      case 'he':
        return 'He';
      
      // Counting simplified descriptions (Numbers)
      case 'one':
        return '1';
      case 'two':
        return '2';
      case 'three':
        return '3';
      case 'four':
        return '4';
      case 'five':
        return '5';
      case 'six':
        return '6';
      case 'seven':
        return '7';
      case 'eight':
        return '8';
      case 'nine':
        return '9';
      case 'ten':
        return '10';
        
      // Shapes and Patterns simplified descriptions
      case 'circle':
        return 'Circle';
      case 'square':
        return 'Square';
      case 'triangle':
        return 'Triangle';
      case 'rectangle':
        return 'Rectangle';
      case 'oval':
        return 'Oval';
      case 'star':
        return 'Star';
      case 'diamond':
        return 'Diamond';
      case 'heart':
        return 'Heart';
      case 'pentagon':
        return 'Pentagon';
      case 'hexagon':
        return 'Hexagon';
        
      // Gross Motor Skills simplified descriptions
      case 'running':
        return 'Running';
      case 'jumping':
        return 'Jumping';
      case 'throwing':
        return 'Throwing';
      case 'kicking':
        return 'Kicking';
      case 'climbing':
        return 'Climbing';
      case 'hopping':
        return 'Hopping';
      case 'balancing':
        return 'Balancing';
      case 'skipping':
        return 'Skipping';
      case 'crawling':
        return 'Crawling';
      case 'dancing':
        return 'Dancing';
        
      // Living and Non-living Things simplified descriptions
      case 'plants':
        return 'Plants';
      case 'animals':
        return 'Animals';
      case 'humans':
        return 'Humans';
      case 'birds':
        return 'Birds';
      case 'insects':
        return 'Insects';
      case 'fish':
        return 'Fish';
      case 'rocks':
        return 'Rocks';
      case 'water':
        return 'Water';
      case 'air':
        return 'Air';
      case 'toys':
        return 'Toys';
      case 'furniture':
        return 'Furniture';
      case 'cloud':
        return 'Cloud';
      case 'sun':
        return 'Sun';
      case 'moon':
        return 'Moon';
      case 'computer':
        return 'Computer';
      case 'car':
        return 'Car';
      
      // Sharing and Cooperation simplified descriptions
      case 'taking turns':
        return 'Wait for turns';
      case 'sharing toys':
        return 'Share toys';
      case 'helping others':
        return 'Help friends';
      case 'listening':
        return 'Listen';
      case 'being kind':
        return 'Be nice';
      case 'teamwork':
        return 'Work together';
      case 'apologizing':
        return 'Say sorry';
      case 'patience':
        return 'Wait calmly';
      case 'empathy':
        return 'Care about others';
      case 'problem solving':
        return 'Fix problems';
      
      // Emotions simplified descriptions
      case 'happy':
        return 'Happy face';
      case 'sad':
        return 'Sad face';
      case 'angry':
        return 'Mad face';
      case 'scared':
        return 'Afraid face';
      case 'excited':
        return 'Very happy face';
      case 'proud':
        return 'Feel good about me';
      case 'surprised':
        return 'Oh! face';
      case 'confused':
        return 'Don\'t understand';
      case 'calm':
        return 'Quiet and still';
      case 'frustrated':
        return 'Can\'t do it face';
      
      // Color Exploration simplified descriptions
      case 'red':
        return 'Red';
      case 'blue':
        return 'Blue';
      case 'yellow':
        return 'Yellow';
      case 'green':
        return 'Green';
      case 'orange':
        return 'Orange';
      case 'purple':
        return 'Purple';
      case 'pink':
        return 'Pink';
      case 'brown':
        return 'Brown';
      case 'black':
        return 'Black';
      case 'white':
        return 'White';
      
      // Lines and Patterns simplified descriptions
      case 'straight line':
        return '——';
      case 'curved line':
        return '~';
      case 'zigzag':
        return '/\\/\\';
      case 'spiral':
        return '@';
      case 'circle pattern':
        return 'OOO';
      case 'checkered pattern':
        return '▒▒';
      case 'stripes':
        return '|||';
      case 'polka dots':
        return '•••';
      case 'symmetry':
        return '◄►';
      case 'repeating pattern':
        return '□○□○';

      // Fine Motor Skills simplified descriptions
      case 'drawing':
        return 'Drawing';
      case 'cutting':
        return 'Cutting';
      case 'buttoning':
        return 'Buttoning';
      case 'beading':
        return 'Beading';
      case 'coloring':
        return 'Coloring';
      case 'folding':
        return 'Folding';
      case 'tracing':
        return 'Tracing';
      case 'zipping':
        return 'Zipping';
      case 'lacing':
        return 'Lacing';
      case 'playdough':
        return 'Playdough';
        
      // Jawi Letters simplified descriptions
      case 'alif':
        return 'ا';
      case 'ba':
        return 'ب';
      case 'ta':
        return 'ت';
      case 'tsa':
        return 'ث';
      case 'jim':
        return 'ج';
      case 'ha':
        return 'ح';
      case 'kha':
        return 'خ';
      case 'dal':
        return 'د';
      case 'dzal':
        return 'ذ';
      case 'ra':
        return 'ر';
        
      // Jawi Simple Writing simplified descriptions
      case 'saya':
        return 'سايا';
      case 'kamu':
        return 'كامو';
      case 'dia':
        return 'دي';
      case 'kita':
        return 'كيت';
      case 'ibu':
        return 'ايبو';
      case 'bapa':
        return 'باڤ';
      case 'makan':
        return 'ماكن';
      case 'minum':
        return 'مينوم';
      case 'sekolah':
        return 'سكوله';
      case 'rumah':
        return 'روماه';
        
      // Basic Iqraa Reading simplified descriptions
      case 'alif fathah':
        return 'اَ';
      case 'ba fathah':
        return 'بَ';
      case 'ta fathah':
        return 'تَ';
      case 'tha fathah':
        return 'ثَ';
      case 'jim fathah':
        return 'جَ';
      case 'ha fathah':
        return 'حَ';
      case 'kha fathah':
        return 'خَ';
      case 'dal fathah':
        return 'دَ';
      case 'dzal fathah':
        return 'ذَ';
      case 'ra fathah':
        return 'رَ';
        
      default:
        return title;
    }
  }
  
  /// Create an enhanced description for older children (age 6)
  static String _createEnhancedDescription(String baseDescription, String title) {
    // For age 6, provide more detailed descriptions
    switch (title.toLowerCase()) {
      // English alphabet enhanced descriptions
      case 'apple':
        return 'A is for Apple. Apples are crunchy fruits that grow on trees. They can be red, green, or yellow and are packed with vitamins.';
      case 'ball':
        return 'B is for Ball. Balls come in many sizes and colors. We use them for different sports like soccer, basketball, and tennis.';
      case 'cat':
        return 'C is for Cat. Cats are furry pets with whiskers. They like to purr when happy and can see well in the dark.';
      case 'dog':
        return 'D is for Dog. Dogs are loyal pets that come in many breeds. They can be trained to follow commands and help people.';
      case 'elephant':
        return 'E is for Elephant. Elephants are the largest land animals. They have long trunks to pick up food and water, and big ears to keep cool.';
      case 'fish':
        return 'F is for Fish. Fish live in water and breathe through gills. There are thousands of different types of fish in our oceans, rivers, and lakes.';
      case 'goat':
        return 'G is for Goat. Goats are farm animals that can climb very well. They give us milk which can be made into cheese.';
      case 'house':
        return 'H is for House. Houses are buildings where people live. They can be small or big, and have different rooms for eating, sleeping, and playing.';
      case 'ice cream':
        return 'I is for Ice Cream. Ice cream is a frozen dessert that comes in many flavors like chocolate, vanilla, and strawberry.';
      case 'jacket':
        return 'J is for Jacket. Jackets keep us warm when it\'s cold outside. They can be made of different materials like wool, cotton, or nylon.';
      case 'kite':
        return 'K is for Kite. Kites fly high in the sky when there\'s wind. They come in many colorful shapes and designs.';
      case 'lion':
        return 'L is for Lion. Lions are powerful wild cats known as the "king of the jungle". Male lions have a special mane of fur around their neck.';
      case 'monkey':
        return 'M is for Monkey. Monkeys are clever animals that can use their hands like humans. They can swing from tree to tree using their arms and tails.';
      case 'nest':
        return 'N is for Nest. Nests are homes that birds build to lay their eggs and raise their babies. They use twigs, leaves, and other materials.';
      case 'orange':
        return 'O is for Orange. Oranges are juicy citrus fruits full of vitamin C. They have a sweet taste and a bright orange color.';
      case 'penguin':
        return 'P is for Penguin. Penguins are birds that cannot fly but are excellent swimmers. They live in cold places like Antarctica.';
      case 'queen':
        return 'Q is for Queen. A queen rules a country or kingdom. In chess, the queen is the most powerful piece on the board.';
      case 'rabbit':
        return 'R is for Rabbit. Rabbits have long ears and hop around. They love to eat carrots and other vegetables.';
      case 'sun':
        return 'S is for Sun. The sun gives us light and heat during the day. It\'s a star at the center of our solar system.';
      case 'turtle':
        return 'T is for Turtle. Turtles move slowly and carry their homes on their backs. Some turtles live for more than 100 years!';
      case 'umbrella':
        return 'U is for Umbrella. Umbrellas keep us dry when it rains. They open up like a shield to protect us from water.';
      case 'violin':
        return 'V is for Violin. Violins are musical instruments with strings. Musicians use a bow to make beautiful sounds.';
      case 'whale':
        return 'W is for Whale. Whales are the largest animals in the ocean. They breathe air through blowholes on top of their heads.';
      case 'xylophone':
        return 'X is for Xylophone. Xylophones are musical instruments with colorful bars. You hit them with mallets to make different sounds.';
      case 'yacht':
        return 'Y is for Yacht. Yachts are special boats used for fun and travel on water. They can be very luxurious.';
      case 'zebra':
        return 'Z is for Zebra. Zebras have black and white stripes that make them unique. No two zebras have the same pattern of stripes!';
        
      // English sight words enhanced descriptions
      case 'the':
        return 'The word "the" is called a definite article. We use it to point to a specific thing. For example, "the book" means a particular book we are talking about.';
      case 'and':
        return 'The word "and" is used to join words or ideas together. For example, when we say "apples and oranges", we are talking about both fruits together.';
      case 'a':
        return 'The word "a" is called an indefinite article. We use it when talking about any one thing, not a specific one. For example, "a dog" could be any dog.';
      case 'to':
        return 'The word "to" helps show direction or purpose. We can say "I went to school" to show where we went, or "I want to learn" to show our purpose.';
      case 'in':
        return 'The word "in" tells us about position or location. When something is inside or within something else, we use "in". For example, "The toy is in the box".';
      case 'is':
        return 'The word "is" tells us about what something or someone is like or what they are doing right now. For example, "The sky is blue" or "She is singing".';
      case 'you':
        return 'The word "you" refers to the person we are speaking to. It\'s a way to directly address someone in a sentence, like when we say "You are my friend".';
      case 'that':
        return 'The word "that" helps us point to a specific thing or person that might be farther away. For example, "I like that book" or "That is my teacher".';
      case 'it':
        return 'The word "it" replaces the name of an object or animal when we\'ve already mentioned it. For example, "I have a ball. It is red."';
      case 'he':
        return 'The word "he" refers to a boy or man when we\'ve already mentioned him. For example, "This is Tom. He is my brother."';
        
      // Living and Non-living Things enhanced descriptions
      case 'plants':
        return 'Plants are living organisms that make their own food through photosynthesis. They need sunlight, water, air, and soil to grow.';
      case 'animals':
        return 'Animals are living organisms that need food, water and oxygen to survive. Unlike plants, animals cannot make their own food.';
      case 'humans':
        return 'Humans are special living beings who can think, talk, and create things. We have a body with parts like the head, arms, legs, and organs inside that help us live.';
      case 'birds':
        return 'Birds are living creatures with feathers, wings, and beaks. Most birds can fly, but some like penguins and ostriches cannot.';
      case 'insects':
        return 'Insects are small living creatures with six legs and three body parts: head, thorax, and abdomen. Most insects have wings and antennae to sense their environment.';
      case 'fish':
        return 'Fish are living creatures that live in water. They have scales on their bodies, fins to help them swim, and gills to breathe underwater.';
      case 'rocks':
        return 'Rocks are non-living things formed from minerals. They don\'t grow, eat, breathe or reproduce like living things do. Rocks can be different colors, shapes, and sizes.';
      case 'water':
        return 'Water is a non-living substance that has no fixed shape and takes the form of its container. It exists in three forms: liquid water, solid ice, and gaseous water vapor.';
      case 'air':
        return 'Air is a non-living mixture of gases that surrounds our Earth. We cannot see air, but we can feel it when the wind blows. Air is made up mostly of nitrogen and oxygen, plus small amounts of other gases.';
      case 'toys':
        return 'Toys are non-living objects made by humans for play and enjoyment. They can be made from different materials like plastic, wood, cloth, or metal. Toys don\'t grow, eat, or breathe like living things.';
      case 'furniture':
        return 'Furniture items are non-living objects made by people for functional purposes. Things like chairs, tables, beds, and cupboards are designed to make our homes and buildings useful and comfortable.';
      case 'cloud':
        return 'Clouds are non-living collections of tiny water droplets or ice crystals floating in the air. They form when warm air rises and cools, causing water vapor to condense.';
      case 'sun':
        return 'The Sun is a non-living star at the center of our solar system. It is a giant ball of hot gases, mainly hydrogen and helium. The Sun provides light and heat that makes life on Earth possible.';
      case 'moon':
        return 'The Moon is a non-living natural satellite that orbits around Earth. It doesn\'t produce its own light but reflects sunlight, which is why we can see it at night.';
      case 'computer':
        return 'A computer is a non-living electronic device designed by humans to process information. It can perform calculations, store data, and run programs to help us work, learn, and play.';
      case 'car':
        return 'A car is a non-living machine made by humans for transportation. Cars have wheels, engines, seats, and many other parts that work together. They need fuel or electricity to run but don\'t grow or reproduce like living things.';
        
      // Sharing and Cooperation enhanced descriptions
      case 'taking turns':
        return 'Taking turns means waiting patiently while someone else has a chance to speak or play, and then having your chance afterward. It\'s an important skill that shows respect for others. When we take turns, games and conversations are fair for everyone.';
      case 'sharing toys':
        return 'Sharing toys means letting others use or play with things that belong to you. When we share, we show generosity and kindness to others. Sharing helps create friendships and teaches us that joy can come from giving, not just receiving.';
      case 'helping others':
        return 'Helping others means offering assistance or support when someone needs it. We can help in many ways: by lending a hand with a difficult task, teaching someone a skill we know, or offering comfort when someone is sad.';
      case 'listening':
        return 'Listening is paying full attention when someone is speaking. Good listeners look at the speaker, think about what is being said, and ask questions to understand better. Listening is different from just hearing—it requires focus and respect.';
      case 'being kind':
        return 'Being kind means doing and saying things that are helpful, generous, and considerate of others\'s feelings. Kindness includes simple actions like sharing, using polite words like "please" and "thank you," including others in activities, and offering help.';
      case 'teamwork':
        return 'Teamwork means people working together toward a common goal. When we work as a team, we combine different strengths and ideas to solve problems better than we could alone. Good teamwork requires communication, compromise, and respecting each team member\'s contributions.';
      case 'apologizing':
        return 'Apologizing means saying "I\'m sorry" when we make a mistake or hurt someone\'s feelings. A sincere apology shows that we understand what we did wrong and care about the other person\'s feelings. After apologizing, we should try not to repeat the same mistake.';
      case 'patience':
        return 'Patience is the ability to stay calm and wait without getting frustrated or upset. We show patience when we wait for our turn, when something takes a long time, or when we\'re learning something new that\'s difficult.';
      case 'empathy':
        return 'Empathy means understanding and caring about how other people feel. It\'s like putting yourself in someone else\'s shoes to see things from their perspective. When someone is sad, happy, or scared, empathy helps us respond in a caring way.';
      case 'problem solving':
        return 'Problem solving is finding good solutions when things go wrong or when facing a challenge. It involves identifying what the problem is, thinking of possible solutions, trying them out, and seeing what works best.';
        
      // Emotions enhanced descriptions
      case 'happy':
        return 'Happiness is a positive emotion that makes us feel good inside. When we are happy, we often smile, laugh, and want to share our joy with others.';
      case 'sad':
        return 'Sadness is an emotion we feel when something disappointing or upsetting happens. When we are sad, we might cry or want to be alone.';
      case 'angry':
        return 'Anger is a strong emotion that we might feel when something seems unfair or when we\'re frustrated. When angry, our heart beats faster and we might want to yell or stomp.';
      case 'scared':
        return 'Fear is an emotion that helps protect us from danger. When we\'re scared, our bodies get ready to react quickly—our heart beats faster and we breathe more rapidly.';
      case 'excited':
        return 'Excitement is a happy, energetic feeling we get when we\'re looking forward to something special or experiencing something new.';
      case 'proud':
        return 'Pride is a good feeling we get when we accomplish something difficult or do something kind. When we feel proud, we stand taller and want to share our achievement.';
      case 'surprised':
        return 'Surprise is the feeling we get when something unexpected happens. Our eyes get big, our eyebrows go up, and sometimes we gasp or say "Wow!"';
      case 'confused':
        return 'Confusion happens when something doesn\'t make sense to us or when we don\'t understand what to do. When confused, we might wrinkle our forehead, tilt our head, or say "Huh?"';
      case 'calm':
        return 'Calmness is a peaceful, relaxed feeling where we\'re not too excited or upset. When calm, our breathing is slow and even, our muscles are relaxed, and our mind feels clear.';
      case 'frustrated':
        return 'Frustration is what we feel when we\'re trying to do something that\'s difficult or when we can\'t get what we want. It can make us feel hot, tense, or like giving up.';
        
      // Color Exploration enhanced descriptions
      case 'red':
        return 'Red is a primary color that can\'t be made by mixing other colors. It reminds us of things like fire trucks, strawberries, and stop signs. Red is often associated with strong feelings like excitement and passion.';
      case 'blue':
        return 'Blue is a primary color found abundantly in nature—in the sky and in bodies of water like oceans and lakes. Blue comes in many shades from light baby blue to deep navy. It often makes people feel calm and peaceful.';
      case 'yellow':
        return 'Yellow is a primary color associated with sunshine and happiness. It\'s one of the most visible colors and catches our attention quickly—that\'s why school buses and some warning signs are yellow.';
      case 'green':
        return 'Green is a secondary color made by mixing blue and yellow. It\'s the color most commonly found in plants due to chlorophyll, which helps plants make food from sunlight. Green often represents growth, nature, and environmental awareness.';
      case 'orange':
        return 'Orange is a secondary color created by mixing red and yellow. It\'s named after the fruit! Orange is energetic and warm like red but more friendly and approachable.';
      case 'purple':
        return 'Purple is a secondary color made by mixing red and blue. Historically, purple dye was very rare and expensive, so it became associated with royalty and wealth.';
      case 'pink':
        return 'Pink is created by mixing red and white. It\'s often described as a lighter version of red. Pink is associated with sweetness, kindness, and nurturing feelings.';
      case 'brown':
        return 'Brown is a composite color made by mixing red, yellow, and black, or by mixing complementary colors like blue and orange. Brown is abundant in nature—in soil, tree trunks, and many animal colors. It represents earthiness, reliability, and stability.';
      case 'white':
        return 'White is the presence of all visible light colors combined. White surfaces reflect all light rather than absorbing it, which is why white clothing feels cooler in the sunshine. White is associated with cleanliness, simplicity, and new beginnings.';
        
      // Lines and Patterns enhanced descriptions
      case 'straight line':
        return 'A straight line is the shortest path between two points. Straight lines don\'t bend or curve and continue in the same direction forever unless something stops them.';
      case 'curved line':
        return 'A curved line changes direction gradually and smoothly, like a gentle bend in a road. Curves don\'t have sharp corners or angles.';
      case 'zigzag':
        return 'A zigzag is a pattern made of connected straight lines that form sharp turns and angles, creating a series of peaks and valleys. Zigzags change direction suddenly and repeatedly.';
      case 'spiral':
        return 'A spiral is a curved line that winds around a center point, getting either closer to or farther from the center as it goes around.';
      case 'circle pattern':
        return 'A circle pattern uses repeated circles arranged in specific ways. Circles are perfect round shapes where every point on the edge is the same distance from the center.';
      case 'checkered pattern':
        return 'A checkered pattern is made of squares arranged in alternating colors, like a chess board or checkers game board. This pattern creates a grid where each square touches others on its sides.';
      case 'stripes':
        return 'Stripes are parallel lines of different colors or textures that create a repeated pattern. Stripes can be any width and can run in any direction, though horizontal and vertical stripes are most common.';
      case 'polka dots':
        return 'Polka dots are a pattern of equally sized circles arranged in a grid or scattered evenly across a background. The name comes from the polka dance that was popular when the pattern became fashionable.';
      case 'symmetry':
        return 'Symmetry occurs when one half of something mirrors the other half exactly. If you could fold it along a line (called the line of symmetry), the two sides would match perfectly.';
      case 'repeating pattern':
        return 'A repeating pattern is a design where the same elements occur over and over in a predictable way. The repeated unit is called a "motif." Repeating patterns can be simple, like stripes, or complex with many different elements that repeat together.';
        
      // Math Counting enhanced descriptions
      case 'one':
        return 'One is the first counting number. It represents a single item or unit. In mathematics, one is the multiplicative identity, which means that when you multiply any number by one, you get the same number. One is also important as a starting point for counting and measuring things.';
      case 'two':
        return 'Two is the number that comes after one. It represents a pair of items. Two is the only even prime number in mathematics. When we group things in twos, we call it "pairing." Our bodies have many parts that come in twos: two eyes, two ears, two arms, and two legs.';
      case 'three':
        return 'Three is the number that comes after two. Many important things come in threes: traffic lights have three colors, stories have a beginning, middle, and end, and triangles have three sides. Three is considered a special number in many cultures and appears in many fairy tales, like the three little pigs or three wishes.';
      case 'four':
        return 'Four is the number that comes after three. It\'s the first number that isn\'t prime because we can make it by multiplying 2×2. Four appears in many places: seasons of the year (spring, summer, fall, winter), directions (north, south, east, west), and a square has four sides and four corners.';
      case 'five':
        return 'Five is the number that comes after four. We have five fingers on each hand and five toes on each foot, which makes counting to five very natural for humans. A pentagon has five sides, and a star often has five points. Five is also half of ten, which is the base of our number system.';
      case 'six':
        return 'Six is the number that comes after five. It\'s the first "perfect number" in mathematics because its factors (1, 2, and 3) add up to six. Honeycomb cells have six sides, making a hexagon shape. Six is also the number of faces on a cube, which is the shape of dice used in many games.';
      case 'seven':
        return 'Seven is the number that comes after six. It appears in many important groupings: seven days in a week, seven colors in a rainbow (red, orange, yellow, green, blue, indigo, violet), and seven notes in a musical scale (do, re, mi, fa, sol, la, ti). Seven is considered a lucky number in many cultures.';
      case 'eight':
        return 'Eight is the number that comes after seven. It\'s a special number because it\'s 2×2×2, which makes it a cube number. When we write eight sideways, it looks like the infinity symbol (∞). An octagon has eight sides, and a spider has eight legs. In music, an octave has eight notes including the starting and ending notes.';
      case 'nine':
        return 'Nine is the number that comes after eight. It\'s the square of three (3×3=9). Nine is interesting because when you multiply it by any number and add the digits of the result together, you always get nine again! For example, 9×5=45, and 4+5=9. In baseball, there are nine players on each team and nine innings in a game.';
      case 'ten':
        return 'Ten is the number that comes after nine. Our number system is based on ten, which is called the decimal system, probably because we have ten fingers to count on. Ten is important for place value - when we count past nine, we start a new column. We have ten digits (0-9) that we use to write all numbers.';
        
      // Math Shapes enhanced descriptions
      case 'circle':
        return 'A circle is a perfectly round shape where every point on the edge is the same distance from the center point.';
      case 'square':
        return 'A square is a shape with four equal sides and four right angles (90 degrees). All sides are the same length.';
      case 'triangle':
        return 'A triangle has three sides and three angles. Triangles are very strong shapes used in buildings and bridges.';
      case 'rectangle':
        return 'A rectangle has four sides with four right angles. Opposite sides are equal in length.';
      case 'oval':
        return 'An oval is an elongated circle, shaped like an egg.';
      case 'star':
        return 'A star shape typically has five or more points extending from a center.';
      case 'diamond':
        return 'A diamond shape is a square turned 45 degrees, where all sides are equal but the angles aren\'t right angles.';
      case 'heart':
        return 'The heart shape represents love and caring.';
      case 'pentagon':
        return 'A pentagon has five sides and five angles.';
      case 'hexagon':
        return 'A hexagon has six sides and six angles.';
        
      // Science Five Senses enhanced descriptions
      case 'sight':
        return 'Sight, or vision, is the sense that lets us see the world through our eyes.';
      case 'hearing':
        return 'Hearing is the sense that allows us to detect sounds through our ears.';
      case 'smell':
        return 'Smell, or olfaction, is the sense that lets us detect chemicals in the air.';
      case 'taste':
        return 'Taste, or gustation, is the sense that allows us to detect flavors in food using our taste buds.';
      case 'touch':
        return 'Touch is the sense that lets us feel pressure, temperature, pain, and texture through our skin.';
        
      // Fine Motor Skills enhanced descriptions
      case 'buttoning':
        return 'Buttoning is pushing buttons through small holes to fasten clothes. This skill requires coordination between your fingers and eyes. Mastering buttoning helps children become more independent with dressing themselves.';
      case 'beading':
        return 'Beading is putting beads onto string or wire to make jewelry or decorations. It requires good hand-eye coordination and finger control to pick up and thread small beads. Beading helps develop patience and attention to detail.';
      case 'coloring':
        return 'Coloring is filling areas with colors using crayons, colored pencils, or markers. It helps develop control of hand movements and staying within lines. Coloring allows for creative expression through color choices and combinations.';
      case 'folding':
        return 'Folding is bending paper or fabric neatly along straight lines. Paper folding (origami) can create amazing shapes like animals or flowers. Folding requires attention to detail and helps develop spatial awareness.';
      case 'tracing':
        return 'Tracing is drawing over existing lines to copy a shape or letter. It helps learn how to form shapes and letters correctly. Tracing builds the muscle memory and precision needed for writing.';
      case 'zipping':
        return 'Zipping is closing a zipper by bringing together two rows of interlocking teeth. It requires coordination to hold the zipper pull and move it smoothly. This skill helps children become independent with dressing.';
      case 'lacing':
        return 'Lacing is threading string or shoelaces through holes in a pattern. This skill builds finger strength and coordination needed for tying shoelaces. Lacing activities include sewing cards and craft projects.';
      case 'playdough':
        return 'Playdough is soft clay that can be shaped with your fingers. You can squeeze, roll, flatten, and mold it into many different shapes. Playing with playdough strengthens the small muscles in fingers and hands.';
        
      // Gross Motor Skills enhanced descriptions
      case 'running':
        return 'Running is moving quickly on your feet, faster than walking. When you run, there are moments when both feet are off the ground. Running helps make your heart and lungs stronger.';
      case 'jumping':
        return 'Jumping is pushing off the ground with your feet and lifting your whole body into the air. You can jump up, forward, or over things. Jumping builds leg strength and coordination.';
      case 'throwing':
        return 'Throwing is using your arm to send an object through the air. When you throw, you use muscles in your fingers, hand, arm, shoulder, and even your legs for balance. Good throwing requires coordination and timing.';
      case 'kicking':
        return 'Kicking is using your foot to hit something, usually to make it move. Soccer players kick balls to score goals. Kicking uses leg muscles and requires good balance to stand on one foot.';
      case 'climbing':
        return 'Climbing is moving up using your hands and feet. You can climb stairs, ladders, playground equipment, or climbing walls. Climbing builds strength in your arms and legs.';
      case 'hopping':
        return 'Hopping is jumping on one foot. It requires good balance and leg strength. Hopping on one foot is more challenging than jumping with both feet. This skill helps develop coordination.';
      case 'balancing':
        return 'Balancing is keeping your body steady without falling. Walking on a balance beam or standing on one foot requires balance. Your inner ears help your brain know if you\'re balanced.';
      case 'skipping':
        return 'Skipping is moving forward by stepping with one foot and hopping on the other in a pattern. It\'s more advanced than walking or running. Skipping combines several movement skills together.';
        
      // Malay letters enhanced descriptions
      case 'ayam':
        return 'Ini ayam, ayam bunyi berkokok.';
      case 'bola':
        return 'Ini bola, bola boleh ditendang.';
      case 'cacing':
        return 'Ini cacing, cacing hidup dalam tanah.';
      case 'durian':
        return 'Ini durian, durian raja buah-buahan.';
      case 'epal':
        return 'Ini epal, epal buah yang sihat.';
      case 'foto':
        return 'Ini foto, foto merakam kenangan.';
      case 'gajah':
        return 'Ini gajah, gajah haiwan yang besar.';
      case 'harimau':
        return 'Ini harimau, harimau raja hutan.';
      case 'ikan':
        return 'Ini ikan, ikan hidup dalam air.';
      case 'jeruk':
        return 'Ini jeruk, jeruk buah yang masam.';
      case 'kucing':
        return 'Ini kucing, kucing bunyi meow.';
      case 'lampu':
        return 'Ini lampu, lampu memberi cahaya.';
      case 'meja':
        return 'Ini meja, meja untuk meletak barang.';
      case 'nanas':
        return 'Ini nanas, nanas buah yang manis.';
      case 'orang':
        return 'Ini orang, orang hidup bersama.';
      case 'pokok':
        return 'Ini pokok, pokok memberi oksigen.';
        
      // Malay simple words enhanced descriptions
      case 'saya':
        return 'Ini saya, saya bermaksud diri sendiri. Kita gunakan perkataan ini untuk merujuk kepada diri kita.';
      case 'kamu':
        return 'Ini kamu, kamu bermaksud orang yang kita ajak berbual. Kita gunakan perkataan ini semasa bercakap dengan seseorang.';
      case 'makan':
        return 'Ini makan, makan adalah perbuatan memasukkan makanan ke dalam mulut dan mengunyahnya. Kita perlu makan untuk mendapat tenaga.';
      case 'minum':
        return 'Ini minum, minum adalah perbuatan memasukkan air atau cecair ke dalam mulut. Air sangat penting untuk kesihatan badan kita.';
      case 'tidur':
        return 'Ini tidur, tidur adalah masa untuk rehat dan memulihkan tenaga. Semasa tidur, badan dan otak kita berehat.';
      case 'baca':
        return 'Ini baca, baca adalah aktiviti melihat dan memahami perkataan dalam buku atau cerita. Membaca membantu kita belajar banyak perkara baru.';
      case 'tulis':
        return 'Ini tulis, tulis adalah aktiviti mencatat huruf dan perkataan di atas kertas menggunakan pensel atau pen. Menulis membantu kita berkongsi idea.';
      case 'lari':
        return 'Ini lari, lari adalah bergerak dengan kaki dengan cepat. Lari adalah senaman yang baik untuk kesihatan kita.';
      case 'main':
        return 'Ini main, main adalah aktiviti yang menyeronokkan untuk kanak-kanak. Bermain membantu kita belajar dan membina kemahiran baru.';
      case 'suka':
        return 'Ini suka, suka adalah rasa gembira terhadap sesuatu. Bila kita suka sesuatu, kita rasa bahagia dan gembira.';
        
      // Jawi Letters enhanced descriptions
      case 'alif':
        return 'Alif (ا) adalah huruf pertama dalam abjad Jawi. Ia tidak mempunyai titik dan ditulis seperti garisan menegak. Alif digunakan untuk menghasilkan bunyi vokal "a" dan merupakan asas untuk banyak perkataan dalam bahasa Melayu dan Arab.';
      case 'ba':
        return 'Ba (ب) adalah huruf kedua dalam abjad Jawi. Ia mempunyai satu titik di bawah dan menghasilkan bunyi "b". Ba digunakan dalam banyak perkataan seperti "buku", "baik" dan "bulan". Bentuknya seperti perahu terbalik dengan titik di bawah.';
      case 'ta':
        return 'Ta (ت) adalah huruf ketiga dalam abjad Jawi. Ia mempunyai dua titik di atas dan menghasilkan bunyi "t". Ta digunakan dalam perkataan seperti "taman", "topi" dan "telur". Bentuknya hampir sama seperti Ba tetapi mempunyai dua titik di atas.';
      case 'tsa':
        return 'Tsa (ث) adalah huruf keempat dalam abjad Jawi. Ia mempunyai tiga titik di atas dan menghasilkan bunyi "ts". Tsa jarang digunakan dalam perkataan Melayu tetapi lebih banyak dalam perkataan Arab. Bentuknya seperti Ta tetapi dengan tiga titik.';
      case 'jim':
        return 'Jim (ج) adalah huruf kelima dalam abjad Jawi. Ia mempunyai satu titik di bawah dan menghasilkan bunyi "j". Jim digunakan dalam perkataan seperti "jalan", "jemu" dan "jumpa". Ia mempunyai bentuk melengkung seperti mangkuk dengan titik di bawah.';
      case 'ha':
        return 'Ha (ح) adalah huruf keenam dalam abjad Jawi. Ia tidak mempunyai titik dan menghasilkan bunyi "h" yang dalam dari kerongkong. Ha digunakan dalam beberapa perkataan Arab dan Melayu. Bentuknya seperti loop yang tidak tertutup sepenuhnya.';
      case 'kha':
        return 'Kha (خ) adalah huruf ketujuh dalam abjad Jawi. Ia mempunyai satu titik di atas dan menghasilkan bunyi "kh". Kha digunakan dalam perkataan seperti "khabar" dan "khemah". Bentuknya seperti Ha tetapi mempunyai satu titik di atas.';
      case 'dal':
        return 'Dal (د) adalah huruf kelapan dalam abjad Jawi. Ia tidak mempunyai titik dan menghasilkan bunyi "d". Dal digunakan dalam perkataan seperti "dua", "datang" dan "duduk". Bentuknya seperti setengah bulatan dengan garisan menegak di sebelah kanan.';
      case 'dzal':
        return 'Dzal (ذ) adalah huruf kesembilan dalam abjad Jawi. Ia mempunyai satu titik di atas dan menghasilkan bunyi "dz". Dzal lebih banyak digunakan dalam perkataan Arab. Bentuknya seperti Dal tetapi mempunyai satu titik di atas.';
      case 'ra':
        return 'Ra (ر) adalah huruf kesepuluh dalam abjad Jawi. Ia tidak mempunyai titik dan menghasilkan bunyi "r". Ra digunakan dalam perkataan seperti "rumah", "rasa" dan "rambut". Bentuknya seperti garisan melengkung dengan ekor pendek di bawah.';
        
      // Jawi Simple Writing enhanced descriptions
      case 'saya':
        return '"Saya" dalam tulisan Jawi ditulis sebagai سايا (Sin-Alif-Ya-Alif). Ia adalah kata ganti nama diri pertama dalam bahasa Melayu yang bermaksud "I" dalam bahasa Inggeris. Perhatikan bagaimana huruf Sin di awal, diikuti oleh Alif, kemudian Ya dan Alif lagi di akhir.';
      case 'kamu':
        return '"Kamu" dalam tulisan Jawi ditulis sebagai كامو (Kaf-Alif-Mim-Wau). Ia adalah kata ganti nama diri kedua dalam bahasa Melayu yang bermaksud "you" dalam bahasa Inggeris. Perhatikan bentuk Kaf yang bersambung dengan Alif, kemudian Mim dan diakhiri dengan Wau.';
      case 'dia':
        return '"Dia" dalam tulisan Jawi ditulis sebagai دي (Dal-Ya). Ia adalah kata ganti nama diri ketiga dalam bahasa Melayu yang bermaksud "he/she" dalam bahasa Inggeris. Ini adalah contoh perkataan pendek yang hanya menggunakan dua huruf: Dal dan Ya.';
      case 'kita':
        return '"Kita" dalam tulisan Jawi ditulis sebagai كيت (Kaf-Ya-Ta). Ia adalah kata ganti nama diri pertama jamak dalam bahasa Melayu yang bermaksud "we" dalam bahasa Inggeris. Perhatikan bagaimana huruf Kaf bersambung dengan Ya dan diakhiri dengan Ta.';
      case 'ibu':
        return '"Ibu" dalam tulisan Jawi ditulis sebagai ايبو (Alif-Ya-Ba-Wau). Ia bermaksud "mother" dalam bahasa Inggeris dan merupakan salah satu perkataan pertama yang dipelajari oleh kanak-kanak. Perhatikan bahawa Alif tidak bersambung dengan huruf selepasnya.';
      case 'bapa':
        return '"Bapa" dalam tulisan Jawi ditulis sebagai باڤ (Ba-Alif-Pa). Ia bermaksud "father" dalam bahasa Inggeris. Perhatikan penggunaan huruf Pa (ڤ) yang mempunyai tiga titik di atas, huruf khas dalam tulisan Jawi untuk bunyi "p".';
      case 'makan':
        return '"Makan" dalam tulisan Jawi ditulis sebagai ماكن (Mim-Alif-Kaf-Nun). Ia adalah kata kerja yang bermaksud "eat" dalam bahasa Inggeris. Perhatikan bagaimana huruf Mim bersambung dengan Alif, kemudian Kaf dan diakhiri dengan Nun.';
      case 'minum':
        return '"Minum" dalam tulisan Jawi ditulis sebagai مينوم (Mim-Ya-Nun-Wau-Mim). Ia adalah kata kerja yang bermaksud "drink" dalam bahasa Inggeris. Ini contoh perkataan yang bermula dan berakhir dengan huruf yang sama - Mim.';
      case 'sekolah':
        return '"Sekolah" dalam tulisan Jawi ditulis sebagai سكوله (Sin-Kaf-Wau-Lam-Ha). Ia bermaksud "school" dalam bahasa Inggeris. Perhatikan bagaimana huruf Sin bersambung dengan Kaf, kemudian Wau (yang tidak bersambung dengan huruf selepasnya), Lam dan Ha.';
      case 'rumah':
        return '"Rumah" dalam tulisan Jawi ditulis sebagai روماه (Ra-Wau-Mim-Alif-Ha). Ia bermaksud "house" dalam bahasa Inggeris. Perhatikan bahawa Ra dan Wau tidak bersambung dengan huruf selepasnya, manakala Mim bersambung dengan Alif dan kemudian Ha.';
        
      // Basic Iqraa Reading enhanced descriptions
      case 'alif fathah':
        return 'Alif dengan baris atas (fathah) dibaca "a" seperti dalam perkataan "ada". Fathah adalah tanda baris berbentuk garisan miring di atas huruf. Apabila kita melihat Alif dengan fathah (اَ), kita menyebutnya dengan bunyi vokal "a" yang jelas dan pendek.';
      case 'ba fathah':
        return 'Ba dengan baris atas (fathah) dibaca "ba" seperti dalam perkataan "batu". Perhatikan titik di bawah huruf Ba yang membezakannya daripada huruf lain. Dengan fathah di atas (بَ), kita menggabungkan bunyi konsonan "b" dengan vokal "a".';
      case 'ta fathah':
        return 'Ta dengan baris atas (fathah) dibaca "ta" seperti dalam perkataan "tali". Perhatikan dua titik di atas huruf Ta yang membezakannya daripada huruf lain. Dengan fathah di atas (تَ), kita menggabungkan bunyi konsonan "t" dengan vokal "a".';
      case 'tha fathah':
        return 'Tha dengan baris atas (fathah) dibaca "tsa" seperti dalam perkataan Inggeris "think". Perhatikan tiga titik di atas huruf Tha. Dengan fathah di atas (ثَ), kita menggabungkan bunyi konsonan "ts" dengan vokal "a".';
      case 'jim fathah':
        return 'Jim dengan baris atas (fathah) dibaca "ja" seperti dalam perkataan "jalan". Perhatikan titik di tengah huruf Jim yang membezakannya daripada huruf lain. Dengan fathah di atas (جَ), kita menggabungkan bunyi konsonan "j" dengan vokal "a".';
      case 'ha fathah':
        return 'Ha dengan baris atas (fathah) dibaca "ha" dengan bunyi "h" yang dalam dari kerongkong. Perhatikan bentuk bulatan huruf Ha tanpa titik. Dengan fathah di atas (حَ), kita menggabungkan bunyi konsonan "h" dengan vokal "a".';
      case 'kha fathah':
        return 'Kha dengan baris atas (fathah) dibaca "kha" seperti dalam perkataan "khabar". Perhatikan satu titik di atas huruf Kha yang membezakannya daripada Ha. Dengan fathah di atas (خَ), kita menggabungkan bunyi konsonan "kh" dengan vokal "a".';
      case 'dal fathah':
        return 'Dal dengan baris atas (fathah) dibaca "da" seperti dalam perkataan "dadu". Perhatikan bentuk Dal yang tidak mempunyai titik. Dengan fathah di atas (دَ), kita menggabungkan bunyi konsonan "d" dengan vokal "a".';
      case 'dzal fathah':
        return 'Dzal dengan baris atas (fathah) dibaca "dza" seperti dalam perkataan Arab "dzahab" (emas). Perhatikan satu titik di atas huruf Dzal yang membezakannya daripada Dal. Dengan fathah di atas (ذَ), kita menggabungkan bunyi konsonan "dz" dengan vokal "a".';
      case 'ra fathah':
        return 'Ra dengan baris atas (fathah) dibaca "ra" seperti dalam perkataan "raja". Perhatikan bentuk Ra yang tidak mempunyai titik dengan ekor melengkung. Dengan fathah di atas (رَ), kita menggabungkan bunyi konsonan "r" dengan vokal "a".';
        
      default:
        // Language-specific defaults based on title
        if (title.split(' ').any((word) => ['a', 'an', 'the', 'is', 'are', 'and', 'to', 'of', 'for', 'with'].contains(word.toLowerCase()))) {
          // If title contains English words, use English format
          return '$title is important to learn about. It helps us understand our world better.';
        } else {
          // Default to Malay format
          return 'Ini $title, $title penting untuk dipelajari.';
        }
    }
  }
  
  // Helper method to get the correct image asset path based on subject
  static String _getImageAssetPath(String subject, String title) {
    // Convert subject to lowercase for comparison
    final lowerSubject = subject.toLowerCase();
    final lowerTitle = title.toLowerCase();
    
    // Map subject names to their asset folder names
    String folderName;
    if (lowerSubject.contains('malay') || lowerSubject == 'bahasa malaysia') {
      folderName = 'malay';
    } else if (lowerSubject == 'mathematics' || lowerSubject == 'math') {
      folderName = 'math';
    } else if (lowerSubject == 'science') {
      folderName = 'science';
    } else if (lowerSubject == 'english') {
      folderName = 'english';
    } else {
      // Default to the lowercase subject name if no special mapping
      folderName = lowerSubject;
    }
    
    // Use the actual image path
    final imagePath = 'assets/flashcards/$folderName/$lowerTitle.png';
    
    // Print the path for debugging
    print('Generated image path: $imagePath');
    
    return imagePath;
  }
  
  /// Get the number of cards to generate based on age
  static int _getCardCountForAge(int age) {
    // For all cases, use age-based counts
    switch (age) {
      case 4:
        return 6; // 6 cards for age 4
      case 5:
        return 8; // 8 cards for age 5
      case 6:
        return 10; // 10 cards for age 6
      default:
        return 8; // Default to 8 cards
    }
  }
  
  /// Generate random pastel color
  static Color _generateRandomColor() {
    final List<Color> colors = [
      const Color(0xFFFFD3B6), // Pastel Orange
      const Color(0xFFFFAAA5), // Pastel Red
      const Color(0xFFFFDBA5), // Pastel Yellow
      const Color(0xFFA5FFD6), // Pastel Green
      const Color(0xFFA5C8FF), // Pastel Blue
      const Color(0xFFD5A5FF), // Pastel Purple
      const Color(0xFFFFA5E0), // Pastel Pink
      const Color(0xFFE5EDB7), // Pastel Lime
    ];
    
    // Use timestamp microseconds to get a "random" index
    final index = DateTime.now().microsecondsSinceEpoch % colors.length;
    return colors[index];
  }
  
  /// Generate flashcards based on subject, chapter, age, and language
  static List<Map<String, dynamic>> generateFlashcards({
    required String subject,
    required String chapter,
    required int age,
    required String language,
    required int count,
  }) {
    // Normalize subject and chapter for comparison
    final normalizedSubject = subject.toLowerCase().trim();
    final normalizedChapter = chapter.toLowerCase().trim();
    
    // Generate flashcards based on subject and chapter
    
    // Bahasa Malaysia
    if (normalizedSubject.contains('bahasa') || normalizedSubject.contains('malay')) {
      if (normalizedChapter.contains('huruf') || normalizedChapter.contains('kata asas') || 
          normalizedChapter.contains('alphabet') || normalizedChapter.contains('letters')) {
        return _generateMalayLettersFlashcards(subject, age, language, count);
      } else if (normalizedChapter.contains('perkataan') || normalizedChapter.contains('mudah') || 
                normalizedChapter.contains('simple words')) {
        return _generateMalaySimpleWordsFlashcards(subject, age, language, count);
      }
    }
    
    // English
    else if (normalizedSubject.contains('english') || normalizedSubject.contains('inggeris')) {
      if (normalizedChapter.contains('alphabet') || normalizedChapter.contains('phonics') || 
          normalizedChapter.contains('letters')) {
        return _generateEnglishAlphabetFlashcards(subject, age, language, count);
      } else if (normalizedChapter.contains('sight') || normalizedChapter.contains('words')) {
        return _generateEnglishSightWordsFlashcards(subject, age, language, count);
      }
    }
    
    // Math
    else if (normalizedSubject.contains('math') || normalizedSubject.contains('matematik')) {
      if (normalizedChapter.contains('counting') || normalizedChapter.contains('numbers') || 
          normalizedChapter.contains('nombor')) {
        return _generateCountingFlashcards(subject, age, language, count);
      } else if (normalizedChapter.contains('shapes') || normalizedChapter.contains('patterns') || 
                normalizedChapter.contains('bentuk')) {
        return _generateShapesAndPatternsFlashcards(subject, age, language, count);
      }
    }
    
    // Science
    else if (normalizedSubject.contains('science') || normalizedSubject.contains('sains')) {
      if (normalizedChapter.contains('five senses') || normalizedChapter.contains('deria')) {
        return _generateFiveSensesFlashcards(subject, age, language, count);
      } else if (normalizedChapter.contains('living') || normalizedChapter.contains('non-living') || 
                normalizedChapter.contains('hidup') || normalizedChapter.contains('bukan hidup')) {
        return _generateLivingNonLivingFlashcards(subject, age, language, count);
      }
    }
    
    // Social & Emotional Learning
    else if (normalizedSubject.contains('social') || normalizedSubject.contains('emotional') || 
             normalizedSubject.contains('sosial') || normalizedSubject.contains('emosi')) {
      if (normalizedChapter.contains('emotions') || normalizedChapter.contains('expressions') || 
          normalizedChapter.contains('emosi') || normalizedChapter.contains('ekspresi')) {
        return _generateEmotionsFlashcards(subject, age, language, count);
      } else if (normalizedChapter.contains('sharing') || normalizedChapter.contains('cooperation') || 
                normalizedChapter.contains('berkongsi') || normalizedChapter.contains('kerjasama')) {
        return _generateSharingCooperationFlashcards(subject, age, language, count);
      }
    }
    
    // Art & Craft
    else if (normalizedSubject.contains('art') || normalizedSubject.contains('craft') || 
             normalizedSubject.contains('seni')) {
      if (normalizedChapter.contains('color') || normalizedChapter.contains('mixing') || 
          normalizedChapter.contains('warna')) {
        return _generateColorExplorationFlashcards(subject, age, language, count);
      } else if (normalizedChapter.contains('lines') || normalizedChapter.contains('patterns') || 
                normalizedChapter.contains('garisan') || normalizedChapter.contains('corak')) {
        return _generateLinesAndPatternsFlashcards(subject, age, language, count);
      }
    }
    
    // Physical Development
    else if (normalizedSubject.contains('physical') || normalizedSubject.contains('motor')) {
      if (normalizedChapter.contains('gross') || normalizedChapter.contains('large')) {
        return _generateGrossMotorSkillsFlashcards(subject, age, language, count);
      } else if (normalizedChapter.contains('fine') || normalizedChapter.contains('small')) {
        return _generateFineMotorSkillsFlashcards(subject, age, language, count);
      }
    }
    
    // Jawi
    else if (normalizedSubject.contains('jawi')) {
      if (normalizedChapter.contains('huruf') || normalizedChapter.contains('letters') || 
          normalizedChapter.contains('pengenalan')) {
        return _generateJawiLettersFlashcards(subject, age, language, count);
      } else if (normalizedChapter.contains('penulisan') || normalizedChapter.contains('writing')) {
        return _generateJawiSimpleWritingFlashcards(subject, age, language, count);
      }
    }
    
    // Hijaiyah / Iqraa
    else if (normalizedSubject.contains('hijaiyah') || normalizedSubject.contains('iqraa') || 
             normalizedSubject.contains('arabic')) {
      if (normalizedChapter.contains('huruf') || normalizedChapter.contains('letters')) {
        return _generateHijaiyahLettersFlashcards(subject, age, language, count);
      } else if (normalizedChapter.contains('bacaan') || normalizedChapter.contains('reading')) {
        return _generateBasicIqraaReadingFlashcards(subject, age, language, count);
      }
    }
    
    // Animals (special case)
    else if (normalizedSubject.contains('animal') || normalizedSubject.contains('haiwan')) {
      return _generateAnimalFlashcards(subject, age, language, count);
    }
    
    // Default to English alphabet if no match
    return _generateDefaultFlashcards(subject, age, language, count);
  }
  
  // Generate Malay letters flashcards
  static List<Map<String, dynamic>> _generateMalayLettersFlashcards(
    String subject, int age, String language, int count) {
  final List<Map<String, dynamic>> flashcards = [
    {
      'title': 'Ayam',
      'letter': 'Aa',
        'description': 'Ayam berkaki dua.',
      'image_asset': 'assets/flashcards/malay/ayam.png',
    },
    {
      'title': 'Bola',
      'letter': 'Bb',
        'description': 'Bola berbentuk bulat.',
      'image_asset': 'assets/flashcards/malay/bola.png',
    },
    {
      'title': 'Cacing',
      'letter': 'Cc',
        'description': 'Cacing tiada kaki.',
      'image_asset': 'assets/flashcards/malay/cacing.png',
    },
    {
      'title': 'Durian',
      'letter': 'Dd',
        'description': 'Durian berbau kuat.',
      'image_asset': 'assets/flashcards/malay/durian.png',
    },
    {
      'title': 'Epal',
      'letter': 'Ee',
        'description': 'Epal berwarna merah.',
      'image_asset': 'assets/flashcards/malay/epal.png',
    },
    {
      'title': 'Foto',
      'letter': 'Ff',
        'description': 'Foto merakam gambar.',
      'image_asset': 'assets/flashcards/malay/foto.png',
    },
    {
      'title': 'Gajah',
      'letter': 'Gg',
        'description': 'Gajah mempunyai belalai.',
      'image_asset': 'assets/flashcards/malay/gajah.png',
    },
    {
      'title': 'Harimau',
      'letter': 'Hh',
        'description': 'Harimau mempunyai belang.',
      'image_asset': 'assets/flashcards/malay/harimau.png',
    },
    {
      'title': 'Ikan',
      'letter': 'Ii',
        'description': 'Ikan bernafas dengan insang.',
      'image_asset': 'assets/flashcards/malay/ikan.png',
    },
    {
      'title': 'Jeruk',
      'letter': 'Jj',
        'description': 'Jeruk rasanya masam.',
      'image_asset': 'assets/flashcards/malay/jeruk.png',
    },
      {
        'title': 'Kucing',
        'letter': 'Kk',
        'description': 'Kucing mempunyai misai.',
        'image_asset': 'assets/flashcards/malay/kucing.png',
      },
      {
        'title': 'Lampu',
        'letter': 'Ll',
        'description': 'Lampu memberikan cahaya.',
        'image_asset': 'assets/flashcards/malay/lampu.png',
      },
      {
        'title': 'Meja',
        'letter': 'Mm',
        'description': 'Meja mempunyai empat kaki.',
        'image_asset': 'assets/flashcards/malay/meja.png',
      },
      {
        'title': 'Nanas',
        'letter': 'Nn',
        'description': 'Nanas mempunyai duri.',
        'image_asset': 'assets/flashcards/malay/nanas.png',
      },
      {
        'title': 'Orang',
        'letter': 'Oo',
        'description': 'Orang mempunyai dua tangan.',
        'image_asset': 'assets/flashcards/malay/orang.png',
      },
      {
        'title': 'Pokok',
        'letter': 'Pp',
        'description': 'Pokok mempunyai daun.',
        'image_asset': 'assets/flashcards/malay/pokok.png',
      },
    ];
    
    print('Generating $count flashcards for age $age');
  return flashcards.take(count).toList();
}

  // Generate Malay simple words flashcards
  static List<Map<String, dynamic>> _generateMalaySimpleWordsFlashcards(
    String subject, int age, String language, int count) {
  final List<Map<String, dynamic>> flashcards = [
    {
      'title': 'Saya',
      'letter': 'Sa',
      'description': 'Saya bermaksud diri sendiri.',
      'image_asset': 'assets/flashcards/malay/saya.png',
    },
    {
      'title': 'Kamu',
      'letter': 'Ka',
      'description': 'Kamu bermaksud orang yang diajak bicara.',
      'image_asset': 'assets/flashcards/malay/kamu.png',
    },
    {
      'title': 'Makan',
      'letter': 'Ma',
      'description': 'Makan adalah perbuatan memasukkan makanan ke dalam mulut.',
      'image_asset': 'assets/flashcards/malay/makan.png',
    },
    {
      'title': 'Minum',
      'letter': 'Mi',
      'description': 'Minum adalah perbuatan memasukkan air ke dalam mulut.',
      'image_asset': 'assets/flashcards/malay/minum.png',
    },
    {
      'title': 'Tidur',
      'letter': 'Ti',
      'description': 'Tidur adalah masa untuk rehat dan memulihkan tenaga.',
      'image_asset': 'assets/flashcards/malay/tidur.png',
    },
    {
      'title': 'Baca',
      'letter': 'Ba',
      'description': 'Baca adalah aktiviti melihat dan memahami tulisan.',
      'image_asset': 'assets/flashcards/malay/baca.png',
    },
    {
      'title': 'Tulis',
      'letter': 'Tu',
      'description': 'Tulis adalah aktiviti mencatat huruf di atas kertas.',
      'image_asset': 'assets/flashcards/malay/tulis.png',
    },
    {
      'title': 'Lari',
      'letter': 'La',
      'description': 'Lari adalah bergerak dengan kaki dengan cepat.',
      'image_asset': 'assets/flashcards/malay/lari.png',
    },
    {
      'title': 'Main',
      'letter': 'Ma',
      'description': 'Main adalah aktiviti yang menyeronokkan untuk kanak-kanak.',
      'image_asset': 'assets/flashcards/malay/main.png',
    },
    {
      'title': 'Suka',
      'letter': 'Su',
      'description': 'Suka adalah rasa gembira terhadap sesuatu.',
      'image_asset': 'assets/flashcards/malay/suka.png',
    },
  ];
  
  return flashcards.take(count).toList();
}

  // Generate English alphabet flashcards
  static List<Map<String, dynamic>> _generateEnglishAlphabetFlashcards(
    String subject, int age, String language, int count) {
  final List<Map<String, dynamic>> flashcards = [
    {
      'title': 'Apple',
      'letter': 'Aa',
      'description': 'A is for Apple, a red fruit that grows on trees.',
      'image_asset': 'assets/flashcards/english/apple.png',
    },
    {
      'title': 'Ball',
      'letter': 'Bb',
      'description': 'B is for Ball, a round toy that bounces.',
      'image_asset': 'assets/flashcards/english/ball.png',
    },
    {
      'title': 'Cat',
      'letter': 'Cc',
      'description': 'C is for Cat, a furry pet that meows.',
      'image_asset': 'assets/flashcards/english/cat.png',
    },
    {
      'title': 'Dog',
      'letter': 'Dd',
      'description': 'D is for Dog, a friendly pet that barks.',
      'image_asset': 'assets/flashcards/english/dog.png',
    },
    {
      'title': 'Elephant',
      'letter': 'Ee',
      'description': 'E is for Elephant, a large animal with a long trunk.',
      'image_asset': 'assets/flashcards/english/elephant.png',
    },
    {
      'title': 'Fish',
      'letter': 'Ff',
      'description': 'F is for Fish, an animal that lives in water.',
      'image_asset': 'assets/flashcards/english/fish.png',
    },
    {
      'title': 'Goat',
      'letter': 'Gg',
      'description': 'G is for Goat, an animal that lives on a farm.',
      'image_asset': 'assets/flashcards/english/goat.png',
    },
    {
      'title': 'House',
      'letter': 'Hh',
      'description': 'H is for House, a place where people live.',
      'image_asset': 'assets/flashcards/english/house.png',
    },
    {
      'title': 'Ice Cream',
      'letter': 'Ii',
      'description': 'I is for Ice Cream, a cold sweet treat.',
      'image_asset': 'assets/flashcards/english/ice_cream.png',
    },
    {
      'title': 'Jacket',
      'letter': 'Jj',
      'description': 'J is for Jacket, clothing that keeps you warm.',
      'image_asset': 'assets/flashcards/english/jacket.png',
    },
  ];
  
  return flashcards.take(count).toList();
}

  // Generate English sight words flashcards
  static List<Map<String, dynamic>> _generateEnglishSightWordsFlashcards(
    String subject, int age, String language, int count) {
  final List<Map<String, dynamic>> flashcards = [
    {
      'title': 'The',
      'letter': 'Th',
      'description': 'The is used before specific or particular nouns.',
      'image_asset': 'assets/flashcards/english/the.png',
    },
    {
      'title': 'And',
      'letter': 'An',
      'description': 'And is used to connect words or groups of words.',
      'image_asset': 'assets/flashcards/english/and.png',
    },
    {
      'title': 'A',
      'letter': 'Aa',
      'description': 'A is used before nouns that begin with a consonant sound.',
      'image_asset': 'assets/flashcards/english/a.png',
    },
    {
      'title': 'To',
      'letter': 'To',
      'description': 'To is used to express motion in the direction of a place.',
      'image_asset': 'assets/flashcards/english/to.png',
    },
    {
      'title': 'In',
      'letter': 'In',
      'description': 'In is used to indicate location or position within something.',
      'image_asset': 'assets/flashcards/english/in.png',
    },
    {
      'title': 'Is',
      'letter': 'Is',
      'description': 'Is means to exist or to be.',
      'image_asset': 'assets/flashcards/english/is.png',
    },
    {
      'title': 'You',
      'letter': 'Yo',
      'description': 'You refers to the person being addressed.',
      'image_asset': 'assets/flashcards/english/you.png',
    },
    {
      'title': 'That',
      'letter': 'Th',
      'description': 'That is used to identify a specific person or thing.',
      'image_asset': 'assets/flashcards/english/that.png',
    },
    {
      'title': 'It',
      'letter': 'It',
      'description': 'It is a pronoun used to refer to a thing previously mentioned.',
      'image_asset': 'assets/flashcards/english/it.png',
    },
    {
      'title': 'He',
      'letter': 'He',
      'description': 'He is used to refer to a male person.',
      'image_asset': 'assets/flashcards/english/he.png',
    },
  ];
  
  return flashcards.take(count).toList();
}

  // Generate counting flashcards
  static List<Map<String, dynamic>> _generateCountingFlashcards(
    String subject, int age, String language, int count) {
  final List<Map<String, dynamic>> flashcards = [
    {
      'title': 'One',
      'letter': '1',
      'description': 'One is the first number in counting.',
      'image_asset': 'assets/flashcards/math/one.png',
    },
    {
      'title': 'Two',
      'letter': '2',
      'description': 'Two is the number after one.',
      'image_asset': 'assets/flashcards/math/two.png',
    },
    {
      'title': 'Three',
      'letter': '3',
      'description': 'Three is the number after two.',
      'image_asset': 'assets/flashcards/math/three.png',
    },
    {
      'title': 'Four',
      'letter': '4',
      'description': 'Four is the number after three.',
      'image_asset': 'assets/flashcards/math/four.png',
    },
    {
      'title': 'Five',
      'letter': '5',
      'description': 'Five is the number after four.',
      'image_asset': 'assets/flashcards/math/five.png',
    },
    {
      'title': 'Six',
      'letter': '6',
      'description': 'Six is the number after five.',
      'image_asset': 'assets/flashcards/math/six.png',
    },
    {
      'title': 'Seven',
      'letter': '7',
      'description': 'Seven is the number after six.',
      'image_asset': 'assets/flashcards/math/seven.png',
    },
    {
      'title': 'Eight',
      'letter': '8',
      'description': 'Eight is the number after seven.',
      'image_asset': 'assets/flashcards/math/eight.png',
    },
    {
      'title': 'Nine',
      'letter': '9',
      'description': 'Nine is the number after eight.',
      'image_asset': 'assets/flashcards/math/nine.png',
    },
    {
      'title': 'Ten',
      'letter': '10',
      'description': 'Ten is the number after nine.',
      'image_asset': 'assets/flashcards/math/ten.png',
    },
  ];
  
  return flashcards.take(count).toList();
}

  // Generate shapes and patterns flashcards
  static List<Map<String, dynamic>> _generateShapesAndPatternsFlashcards(
    String subject, int age, String language, int count) {
  final List<Map<String, dynamic>> flashcards = [
    {
      'title': 'Circle',
      'letter': 'Ci',
      'description': 'A circle is a round shape with no corners.',
      'image_asset': 'assets/flashcards/math/circle.png',
    },
    {
      'title': 'Square',
      'letter': 'Sq',
      'description': 'A square has four equal sides and four corners.',
      'image_asset': 'assets/flashcards/math/square.png',
    },
    {
      'title': 'Triangle',
      'letter': 'Tr',
      'description': 'A triangle has three sides and three corners.',
      'image_asset': 'assets/flashcards/math/triangle.png',
    },
    {
      'title': 'Rectangle',
      'letter': 'Re',
      'description': 'A rectangle has four sides and four corners.',
      'image_asset': 'assets/flashcards/math/rectangle.png',
    },
    {
      'title': 'Oval',
      'letter': 'Ov',
      'description': 'An oval is like a stretched circle.',
      'image_asset': 'assets/flashcards/math/oval.png',
    },
    {
      'title': 'Star',
      'letter': 'St',
      'description': 'A star is a shape with five or more points.',
      'image_asset': 'assets/flashcards/math/star.png',
    },
    {
      'title': 'Diamond',
      'letter': 'Di',
      'description': 'A diamond is a square turned on its corner.',
      'image_asset': 'assets/flashcards/math/diamond.png',
    },
    {
      'title': 'Heart',
      'letter': 'He',
      'description': 'A heart shape represents love and caring.',
      'image_asset': 'assets/flashcards/math/heart.png',
    },
    {
      'title': 'Pentagon',
      'letter': 'Pe',
      'description': 'A pentagon has five sides and five corners.',
      'image_asset': 'assets/flashcards/math/pentagon.png',
    },
    {
      'title': 'Hexagon',
      'letter': 'He',
      'description': 'A hexagon has six sides and six corners.',
      'image_asset': 'assets/flashcards/math/hexagon.png',
    },
  ];
  
  return flashcards.take(count).toList();
}

  // Generate gross motor skills flashcards
  static List<Map<String, dynamic>> _generateGrossMotorSkillsFlashcards(
    String subject, int age, String language, int count) {
  final List<Map<String, dynamic>> flashcards = [
    {
      'title': 'Running',
      'letter': 'Ru',
      'description': 'Running is moving quickly on your feet.',
      'image_asset': 'assets/flashcards/motor/running.png',
    },
    {
      'title': 'Jumping',
      'letter': 'Ju',
      'description': 'Jumping is pushing off the ground with your feet.',
      'image_asset': 'assets/flashcards/motor/jumping.png',
    },
    {
      'title': 'Throwing',
      'letter': 'Th',
      'description': 'Throwing is sending an object through the air with your hand.',
      'image_asset': 'assets/flashcards/motor/throwing.png',
    },
    {
      'title': 'Kicking',
      'letter': 'Ki',
      'description': 'Kicking is hitting something with your foot.',
      'image_asset': 'assets/flashcards/motor/kicking.png',
    },
    {
      'title': 'Climbing',
      'letter': 'Cl',
      'description': 'Climbing is moving up using your hands and feet.',
      'image_asset': 'assets/flashcards/motor/climbing.png',
    },
    {
      'title': 'Hopping',
      'letter': 'Ho',
      'description': 'Hopping is jumping on one foot.',
      'image_asset': 'assets/flashcards/motor/hopping.png',
    },
    {
      'title': 'Balancing',
      'letter': 'Ba',
      'description': 'Balancing is staying steady without falling.',
      'image_asset': 'assets/flashcards/motor/balancing.png',
    },
    {
      'title': 'Skipping',
      'letter': 'Sk',
      'description': 'Skipping is stepping and hopping in a pattern.',
      'image_asset': 'assets/flashcards/motor/skipping.png',
    },
    {
      'title': 'Crawling',
      'letter': 'Cr',
      'description': 'Crawling is moving on hands and knees.',
      'image_asset': 'assets/flashcards/motor/crawling.png',
    },
    {
      'title': 'Dancing',
      'letter': 'Da',
      'description': 'Dancing is moving your body to music.',
      'image_asset': 'assets/flashcards/motor/dancing.png',
    },
  ];
  
  return flashcards.take(count).toList();
}

  // Generate fine motor skills flashcards
  static List<Map<String, dynamic>> _generateFineMotorSkillsFlashcards(
      String subject, int age, String language, int count) {
    final List<Map<String, dynamic>> flashcards = [
      {
        'title': 'Drawing',
        'letter': 'Dr',
        'description': 'Drawing is making pictures with a pencil or crayon.',
        'image_asset': 'assets/flashcards/motor/drawing.png',
      },
      {
        'title': 'Cutting',
        'letter': 'Cu',
        'description': 'Cutting is using scissors to divide paper.',
        'image_asset': 'assets/flashcards/motor/cutting.png',
      },
      {
        'title': 'Buttoning',
        'letter': 'Bu',
        'description': 'Buttoning is fastening clothes with buttons.',
        'image_asset': 'assets/flashcards/motor/buttoning.png',
      },
      {
        'title': 'Beading',
        'letter': 'Be',
        'description': 'Beading is putting beads on a string.',
        'image_asset': 'assets/flashcards/motor/beading.png',
      },
      {
        'title': 'Coloring',
        'letter': 'Co',
        'description': 'Coloring is filling areas with colors using crayons or markers.',
        'image_asset': 'assets/flashcards/motor/coloring.png',
      },
      {
        'title': 'Folding',
        'letter': 'Fo',
        'description': 'Folding is bending paper or fabric neatly.',
        'image_asset': 'assets/flashcards/motor/folding.png',
      },
      {
        'title': 'Tracing',
        'letter': 'Tr',
        'description': 'Tracing is drawing over lines to copy a shape.',
        'image_asset': 'assets/flashcards/motor/tracing.png',
      },
      {
        'title': 'Zipping',
        'letter': 'Zi',
        'description': 'Zipping is closing a zipper on clothing or bags.',
        'image_asset': 'assets/flashcards/motor/zipping.png',
      },
      {
        'title': 'Lacing',
        'letter': 'La',
        'description': 'Lacing is threading string through holes.',
        'image_asset': 'assets/flashcards/motor/lacing.png',
      },
      {
        'title': 'Playdough',
        'letter': 'Pl',
        'description': 'Playdough is shaping soft clay with your fingers.',
        'image_asset': 'assets/flashcards/motor/playdough.png',
      },
    ];
    
    return flashcards.take(count).toList();
  }
  
  // Generate Jawi letters flashcards
  static List<Map<String, dynamic>> _generateJawiLettersFlashcards(
      String subject, int age, String language, int count) {
    final List<Map<String, dynamic>> flashcards = [
      {
        'title': 'Alif',
        'letter': 'ا',
        'description': 'Alif adalah huruf pertama dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/alif.png',
      },
      {
        'title': 'Ba',
        'letter': 'ب',
        'description': 'Ba adalah huruf kedua dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/ba.png',
      },
      {
        'title': 'Ta',
        'letter': 'ت',
        'description': 'Ta adalah huruf ketiga dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/ta.png',
      },
      {
        'title': 'Tsa',
        'letter': 'ث',
        'description': 'Tsa adalah huruf keempat dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/tsa.png',
      },
      {
        'title': 'Jim',
        'letter': 'ج',
        'description': 'Jim adalah huruf kelima dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/jim.png',
      },
      {
        'title': 'Ha',
        'letter': 'ح',
        'description': 'Ha adalah huruf keenam dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/ha.png',
      },
      {
        'title': 'Kha',
        'letter': 'خ',
        'description': 'Kha adalah huruf ketujuh dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/kha.png',
      },
      {
        'title': 'Dal',
        'letter': 'د',
        'description': 'Dal adalah huruf kelapan dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/dal.png',
      },
      {
        'title': 'Dzal',
        'letter': 'ذ',
        'description': 'Dzal adalah huruf kesembilan dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/dzal.png',
      },
      {
        'title': 'Ra',
        'letter': 'ر',
        'description': 'Ra adalah huruf kesepuluh dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/ra.png',
      },
      {
        'title': 'Zai',
        'letter': 'ز',
        'description': 'Zai adalah huruf kesebelas dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/zai.png',
      },
      {
        'title': 'Sin',
        'letter': 'س',
        'description': 'Sin adalah huruf kedua belas dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/sin.png',
      },
      {
        'title': 'Syin',
        'letter': 'ش',
        'description': 'Syin adalah huruf ketiga belas dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/syin.png',
      },
      {
        'title': 'Shad',
        'letter': 'ص',
        'description': 'Shad adalah huruf keempat belas dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/shad.png',
      },
      {
        'title': 'Dhad',
        'letter': 'ض',
        'description': 'Dhad adalah huruf kelima belas dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/dhad.png',
      },
      {
        'title': 'Tha',
        'letter': 'ط',
        'description': 'Tha adalah huruf keenam belas dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/tha.png',
      },
      {
        'title': 'Dza',
        'letter': 'ظ',
        'description': 'Dza adalah huruf ketujuh belas dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/dza.png',
      },
      {
        'title': '\'Ain',
        'letter': 'ع',
        'description': '\'Ain adalah huruf kedelapan belas dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/ain.png',
      },
      {
        'title': 'Ghain',
        'letter': 'غ',
        'description': 'Ghain adalah huruf kesembilan belas dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/ghain.png',
      },
      {
        'title': 'Fa',
        'letter': 'ف',
        'description': 'Fa adalah huruf kedua puluh dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/fa.png',
      },
      {
        'title': 'Qaf',
        'letter': 'ق',
        'description': 'Qaf adalah huruf kedua puluh satu dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/qaf.png',
      },
      {
        'title': 'Kaf',
        'letter': 'ك',
        'description': 'Kaf adalah huruf kedua puluh dua dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/kaf.png',
      },
      {
        'title': 'Lam',
        'letter': 'ل',
        'description': 'Lam adalah huruf kedua puluh tiga dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/lam.png',
      },
      {
        'title': 'Mim',
        'letter': 'م',
        'description': 'Mim adalah huruf kedua puluh empat dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/mim.png',
      },
      {
        'title': 'Nun',
        'letter': 'ن',
        'description': 'Nun adalah huruf kedua puluh lima dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/nun.png',
      },
      {
        'title': 'Wau',
        'letter': 'و',
        'description': 'Wau adalah huruf kedua puluh enam dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/wau.png',
      },
      {
        'title': 'Ha',
        'letter': 'ه',
        'description': 'Ha adalah huruf kedua puluh tujuh dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/ha2.png',
      },
      {
        'title': 'Hamzah',
        'letter': 'ء',
        'description': 'Hamzah adalah huruf kedua puluh delapan dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/hamzah.png',
      },
      {
        'title': 'Ya',
        'letter': 'ي',
        'description': 'Ya adalah huruf kedua puluh sembilan dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/ya.png',
      },
    ];
    
    return flashcards.take(count).toList();
  }
  
  // Generate Jawi simple writing flashcards
  static List<Map<String, dynamic>> _generateJawiSimpleWritingFlashcards(
      String subject, int age, String language, int count) {
    final List<Map<String, dynamic>> flashcards = [
      {
        'title': 'Saya',
        'letter': 'سايا',
        'description': 'Saya dalam tulisan Jawi.',
        'image_asset': 'assets/flashcards/jawi/saya.png',
      },
      {
        'title': 'Kamu',
        'letter': 'كامو',
        'description': 'Kamu dalam tulisan Jawi.',
        'image_asset': 'assets/flashcards/jawi/kamu.png',
      },
      {
        'title': 'Dia',
        'letter': 'دي',
        'description': 'Dia dalam tulisan Jawi.',
        'image_asset': 'assets/flashcards/jawi/dia.png',
      },
      {
        'title': 'Kita',
        'letter': 'كيت',
        'description': 'Kita dalam tulisan Jawi.',
        'image_asset': 'assets/flashcards/jawi/kita.png',
      },
      {
        'title': 'Ibu',
        'letter': 'ايبو',
        'description': 'Ibu dalam tulisan Jawi.',
        'image_asset': 'assets/flashcards/jawi/ibu.png',
      },
      {
        'title': 'Bapa',
        'letter': 'باڤ',
        'description': 'Bapa dalam tulisan Jawi.',
        'image_asset': 'assets/flashcards/jawi/bapa.png',
      },
      {
        'title': 'Makan',
        'letter': 'ماكن',
        'description': 'Makan dalam tulisan Jawi.',
        'image_asset': 'assets/flashcards/jawi/makan.png',
      },
      {
        'title': 'Minum',
        'letter': 'مينوم',
        'description': 'Minum dalam tulisan Jawi.',
        'image_asset': 'assets/flashcards/jawi/minum.png',
      },
      {
        'title': 'Sekolah',
        'letter': 'سكوله',
        'description': 'Sekolah dalam tulisan Jawi.',
        'image_asset': 'assets/flashcards/jawi/sekolah.png',
      },
      {
        'title': 'Rumah',
        'letter': 'روماه',
        'description': 'Rumah dalam tulisan Jawi.',
        'image_asset': 'assets/flashcards/jawi/rumah.png',
      },
    ];
    
    return flashcards.take(count).toList();
  }
  
  // Generate Hijaiyah letters flashcards
  static List<Map<String, dynamic>> _generateHijaiyahLettersFlashcards(
      String subject, int age, String language, int count) {
    final List<Map<String, dynamic>> flashcards = [
      {
        'title': 'Alif',
        'letter': 'ا',
        'description': 'Alif adalah huruf pertama dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/alif.png',
      },
      {
        'title': 'Ba',
        'letter': 'ب',
        'description': 'Ba adalah huruf kedua dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/ba.png',
      },
      {
        'title': 'Ta',
        'letter': 'ت',
        'description': 'Ta adalah huruf ketiga dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/ta.png',
      },
      {
        'title': 'Tha',
        'letter': 'ث',
        'description': 'Tha adalah huruf keempat dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/tha.png',
      },
      {
        'title': 'Jim',
        'letter': 'ج',
        'description': 'Jim adalah huruf kelima dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/jim.png',
      },
      {
        'title': 'Ha',
        'letter': 'ح',
        'description': 'Ha adalah huruf keenam dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/ha.png',
      },
      {
        'title': 'Kha',
        'letter': 'خ',
        'description': 'Kha adalah huruf ketujuh dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/kha.png',
      },
      {
        'title': 'Dal',
        'letter': 'د',
        'description': 'Dal adalah huruf kelapan dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/dal.png',
      },
      {
        'title': 'Dzal',
        'letter': 'ذ',
        'description': 'Dzal adalah huruf kesembilan dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/dzal.png',
      },
      {
        'title': 'Ra',
        'letter': 'ر',
        'description': 'Ra adalah huruf kesepuluh dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/ra.png',
      },
      {
        'title': 'Zai',
        'letter': 'ز',
        'description': 'Zai adalah huruf kesebelas dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/zai.png',
      },
      {
        'title': 'Sin',
        'letter': 'س',
        'description': 'Sin adalah huruf kedua belas dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/sin.png',
      },
      {
        'title': 'Syin',
        'letter': 'ش',
        'description': 'Syin adalah huruf ketiga belas dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/syin.png',
      },
      {
        'title': 'Shad',
        'letter': 'ص',
        'description': 'Shad adalah huruf keempat belas dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/shad.png',
      },
      {
        'title': 'Dhad',
        'letter': 'ض',
        'description': 'Dhad adalah huruf kelima belas dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/dhad.png',
      },
      {
        'title': 'Tha',
        'letter': 'ط',
        'description': 'Tha adalah huruf keenam belas dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/tha2.png',
      },
      {
        'title': 'Dza',
        'letter': 'ظ',
        'description': 'Dza adalah huruf ketujuh belas dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/dza.png',
      },
      {
        'title': '\'Ain',
        'letter': 'ع',
        'description': '\'Ain adalah huruf kedelapan belas dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/ain.png',
      },
      {
        'title': 'Ghain',
        'letter': 'غ',
        'description': 'Ghain adalah huruf kesembilan belas dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/ghain.png',
      },
      {
        'title': 'Fa',
        'letter': 'ف',
        'description': 'Fa adalah huruf kedua puluh dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/fa.png',
      },
      {
        'title': 'Qaf',
        'letter': 'ق',
        'description': 'Qaf adalah huruf kedua puluh satu dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/qaf.png',
      },
      {
        'title': 'Kaf',
        'letter': 'ك',
        'description': 'Kaf adalah huruf kedua puluh dua dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/kaf.png',
      },
      {
        'title': 'Lam',
        'letter': 'ل',
        'description': 'Lam adalah huruf kedua puluh tiga dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/lam.png',
      },
      {
        'title': 'Mim',
        'letter': 'م',
        'description': 'Mim adalah huruf kedua puluh empat dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/mim.png',
      },
      {
        'title': 'Nun',
        'letter': 'ن',
        'description': 'Nun adalah huruf kedua puluh lima dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/nun.png',
      },
      {
        'title': 'Wau',
        'letter': 'و',
        'description': 'Wau adalah huruf kedua puluh enam dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/wau.png',
      },
      {
        'title': 'Ha',
        'letter': 'ه',
        'description': 'Ha adalah huruf kedua puluh tujuh dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/ha2.png',
      },
      {
        'title': 'Ya',
        'letter': 'ي',
        'description': 'Ya adalah huruf kedua puluh delapan dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/ya.png',
      },
    ];
    
    return flashcards.take(count).toList();
  }
  
  // Generate Basic Iqraa reading flashcards
  static List<Map<String, dynamic>> _generateBasicIqraaReadingFlashcards(
      String subject, int age, String language, int count) {
    final List<Map<String, dynamic>> flashcards = [
      {
        'title': 'Alif Fathah',
        'letter': 'اَ',
        'description': 'Alif dengan baris atas dibaca "a".',
        'image_asset': 'assets/flashcards/iqraa/alif_fathah.png',
      },
      {
        'title': 'Ba Fathah',
        'letter': 'بَ',
        'description': 'Ba dengan baris atas dibaca "ba".',
        'image_asset': 'assets/flashcards/iqraa/ba_fathah.png',
      },
      {
        'title': 'Ta Fathah',
        'letter': 'تَ',
        'description': 'Ta dengan baris atas dibaca "ta".',
        'image_asset': 'assets/flashcards/iqraa/ta_fathah.png',
      },
      {
        'title': 'Tha Fathah',
        'letter': 'ثَ',
        'description': 'Tha dengan baris atas dibaca "tsa".',
        'image_asset': 'assets/flashcards/iqraa/tha_fathah.png',
      },
      {
        'title': 'Jim Fathah',
        'letter': 'جَ',
        'description': 'Jim dengan baris atas dibaca "ja".',
        'image_asset': 'assets/flashcards/iqraa/jim_fathah.png',
      },
      {
        'title': 'Ha Fathah',
        'letter': 'حَ',
        'description': 'Ha dengan baris atas dibaca "ha".',
        'image_asset': 'assets/flashcards/iqraa/ha_fathah.png',
      },
      {
        'title': 'Kha Fathah',
        'letter': 'خَ',
        'description': 'Kha dengan baris atas dibaca "kha".',
        'image_asset': 'assets/flashcards/iqraa/kha_fathah.png',
      },
      {
        'title': 'Dal Fathah',
        'letter': 'دَ',
        'description': 'Dal dengan baris atas dibaca "da".',
        'image_asset': 'assets/flashcards/iqraa/dal_fathah.png',
      },
      {
        'title': 'Dzal Fathah',
        'letter': 'ذَ',
        'description': 'Dzal dengan baris atas dibaca "dza".',
        'image_asset': 'assets/flashcards/iqraa/dzal_fathah.png',
      },
      {
        'title': 'Ra Fathah',
        'letter': 'رَ',
        'description': 'Ra dengan baris atas dibaca "ra".',
        'image_asset': 'assets/flashcards/iqraa/ra_fathah.png',
      },
    ];
    
    return flashcards.take(count).toList();
  }
  
  // Generate animal flashcards
  static List<Map<String, dynamic>> _generateAnimalFlashcards(
      String subject, int age, String language, int count) {
    final List<Map<String, dynamic>> flashcards = [
      {
        'title': 'Lion',
        'letter': 'Ll',
        'description': 'Lions are big cats that live in Africa.',
        'image_asset': 'assets/flashcards/animals/lion.png',
      },
      {
        'title': 'Elephant',
        'letter': 'Ee',
        'description': 'Elephants have long trunks and big ears.',
        'image_asset': 'assets/flashcards/animals/elephant.png',
      },
      {
        'title': 'Giraffe',
        'letter': 'Gg',
        'description': 'Giraffes have very long necks.',
        'image_asset': 'assets/flashcards/animals/giraffe.png',
      },
      {
        'title': 'Zebra',
        'letter': 'Zz',
        'description': 'Zebras have black and white stripes.',
        'image_asset': 'assets/flashcards/animals/zebra.png',
      },
    ];
    
    return flashcards.take(count).toList();
  }
  
  // Generate Five Senses flashcards with age-appropriate content
  static List<Map<String, dynamic>> _generateFiveSensesFlashcards(
      String subject, int age, String language, int count) {
    List<Map<String, dynamic>> flashcards = [];
    
    // Base cards for all ages
    final baseCards = [
      {
        'title': 'Sight',
        'letter': 'Ss',
        'image_asset': 'assets/flashcards/science/sight.png',
      },
      {
        'title': 'Hearing',
        'letter': 'Hh',
        'image_asset': 'assets/flashcards/science/hearing.png',
      },
      {
        'title': 'Touch',
        'letter': 'Tt',
        'image_asset': 'assets/flashcards/science/touch.png',
      },
      {
        'title': 'Taste',
        'letter': 'Tt',
        'image_asset': 'assets/flashcards/science/taste.png',
      },
      {
        'title': 'Smell',
        'letter': 'Ss',
        'image_asset': 'assets/flashcards/science/smell.png',
      },
    ];
    
    // Additional cards for older children
    final advancedCards = [
      {
        'title': 'Eyes',
        'letter': 'Ee',
        'image_asset': 'assets/flashcards/science/eyes.png',
      },
      {
        'title': 'Ears',
        'letter': 'Ee',
        'image_asset': 'assets/flashcards/science/ears.png',
      },
      {
        'title': 'Skin',
        'letter': 'Ss',
        'image_asset': 'assets/flashcards/science/skin.png',
      },
      {
        'title': 'Tongue',
        'letter': 'Tt',
        'image_asset': 'assets/flashcards/science/tongue.png',
      },
      {
        'title': 'Nose',
        'letter': 'Nn',
        'image_asset': 'assets/flashcards/science/nose.png',
      },
      {
        'title': 'Brain',
        'letter': 'Bb',
        'image_asset': 'assets/flashcards/science/brain.png',
      },
      {
        'title': 'Fingertips',
        'letter': 'Ff',
        'image_asset': 'assets/flashcards/science/fingertips.png',
      },
      {
        'title': 'Taste Buds',
        'letter': 'Tb',
        'image_asset': 'assets/flashcards/science/taste_buds.png',
      },
      {
        'title': 'Light',
        'letter': 'Li',
        'image_asset': 'assets/flashcards/science/light.png',
      },
      {
        'title': 'Sound',
        'letter': 'So',
        'image_asset': 'assets/flashcards/science/sound.png',
      },
    ];
    
    // Age-specific descriptions
    for (var card in baseCards) {
      var title = card['title'] as String;
      var description = '';
      
      // Different descriptions based on age
      if (age <= 4) {
        // Simple descriptions for younger children
        switch (title) {
          case 'Sight':
            description = 'We see with our eyes.';
            break;
          case 'Hearing':
            description = 'We hear with our ears.';
            break;
          case 'Touch':
            description = 'We feel with our hands.';
            break;
          case 'Taste':
            description = 'We taste with our tongue.';
            break;
          case 'Smell':
            description = 'We smell with our nose.';
            break;
        }
      } else if (age == 5) {
        // More detailed for age 5
        switch (title) {
          case 'Sight':
            description = 'Our eyes help us see colors and shapes.';
            break;
          case 'Hearing':
            description = 'Our ears help us hear sounds and music.';
            break;
          case 'Touch':
            description = 'Our skin helps us feel hot, cold, soft or hard.';
            break;
          case 'Taste':
            description = 'Our tongue helps us taste sweet, sour, salty and bitter.';
            break;
          case 'Smell':
            description = 'Our nose helps us smell flowers, food and more.';
            break;
        }
      } else {
        // Most detailed for age 6
        switch (title) {
          case 'Sight':
            description = 'Our eyes are sense organs that detect light and send signals to our brain so we can see. We use our sight to read, navigate, and appreciate colors.';
            break;
          case 'Hearing':
            description = 'Our ears detect sound vibrations in the air. Hearing helps us communicate, enjoy music, and stay aware of our surroundings.';
            break;
          case 'Touch':
            description = 'Touch receptors in our skin help us feel temperature, pressure, and texture. This sense protects us from danger and helps us explore our world.';
            break;
          case 'Taste':
            description = 'Our tongue has taste buds that detect sweet, sour, salty, bitter and umami flavors. This helps us enjoy food and avoid harmful substances.';
            break;
          case 'Smell':
            description = 'Our nose can detect thousands of different scents. Smell is closely linked with taste and helps us enjoy food and detect dangers like smoke or gas.';
            break;
        }
      }
      
      // Add description to card
      card['description'] = description;
      flashcards.add(card);
    }
    
    // Add additional cards for older ages
    if (age >= 5) {
      for (var card in advancedCards.take(age == 5 ? 3 : 5)) {
        var title = card['title'] as String;
        var description = '';
        
        // Age-specific descriptions for advanced cards
        if (age == 5) {
          // Simpler descriptions for age 5
          switch (title) {
            case 'Eyes':
              description = 'Eyes are organs that help us see.';
              break;
            case 'Ears':
              description = 'Ears are organs that help us hear.';
              break;
            case 'Skin':
              description = 'Skin covers our body and helps us feel touch.';
              break;
            case 'Tongue':
              description = 'Tongue helps us taste food.';
              break;
            case 'Nose':
              description = 'Nose helps us smell different scents.';
              break;
            case 'Brain':
              description = 'Brain helps us think and understand what we sense.';
              break;
            case 'Fingertips':
              description = 'Fingertips help us feel things better.';
              break;
            case 'Taste Buds':
              description = 'Taste buds help us taste different flavors.';
              break;
            case 'Light':
              description = 'Light helps us see things around us.';
              break;
            case 'Sound':
              description = 'Sound is what we hear with our ears.';
              break;
            case 'Skin':
              description = 'Skin is our largest organ. It has receptors that detect touch, temperature, and pain.';
              break;
            case 'Tongue':
              description = 'Our tongue has tiny bumps called taste buds that detect different flavors in food.';
              break;
            case 'Nose':
              description = 'Inside our nose, special cells detect smells and send signals to our brain.';
              break;
          }
        }
        
        // Add description to card
        card['description'] = description;
        flashcards.add(card);
      }
    }
    
    return flashcards.take(count).toList();
  }
  
  // Generate Living vs Non-living Things flashcards with age-appropriate content
  static List<Map<String, dynamic>> _generateLivingNonLivingFlashcards(
      String subject, int age, String language, int count) {
    List<Map<String, dynamic>> flashcards = [];
    
    // Living things
    final livingThings = [
      {
        'title': 'Plants',
        'letter': 'Pp',
        'image_asset': 'assets/flashcards/science/plants.png',
        'category': 'Living',
      },
      {
        'title': 'Animals',
        'letter': 'Aa',
        'image_asset': 'assets/flashcards/science/animals.png',
        'category': 'Living',
      },
      {
        'title': 'Humans',
        'letter': 'Hh',
        'image_asset': 'assets/flashcards/science/humans.png',
        'category': 'Living',
      },
      {
        'title': 'Birds',
        'letter': 'Bb',
        'image_asset': 'assets/flashcards/science/birds.png',
        'category': 'Living',
      },
      {
        'title': 'Insects',
        'letter': 'Ii',
        'image_asset': 'assets/flashcards/science/insects.png',
        'category': 'Living',
      },
      {
        'title': 'Fish',
        'letter': 'Ff',
        'image_asset': 'assets/flashcards/science/fish.png',
        'category': 'Living',
      },
    ];
  
    // Non-living things
    final nonLivingThings = [
      {
        'title': 'Rocks',
        'letter': 'Rr',
        'image_asset': 'assets/flashcards/science/rocks.png',
        'category': 'Non-living',
      },
      {
        'title': 'Water',
        'letter': 'Ww',
        'image_asset': 'assets/flashcards/science/water.png',
        'category': 'Non-living',
      },
      {
        'title': 'Air',
        'letter': 'Aa',
        'image_asset': 'assets/flashcards/science/air.png',
        'category': 'Non-living',
      },
      {
        'title': 'Toys',
        'letter': 'Tt',
        'image_asset': 'assets/flashcards/science/toys.png',
        'category': 'Non-living',
      },
      {
        'title': 'Furniture',
        'letter': 'Ff',
        'image_asset': 'assets/flashcards/science/furniture.png',
        'category': 'Non-living',
      },
      {
        'title': 'Cloud',
        'letter': 'Cc',
        'image_asset': 'assets/flashcards/science/cloud.png',
        'category': 'Non-living',
      },
      {
        'title': 'Sun',
        'letter': 'Ss',
        'image_asset': 'assets/flashcards/science/sun.png',
        'category': 'Non-living',
      },
      {
        'title': 'Moon',
        'letter': 'Mm',
        'image_asset': 'assets/flashcards/science/moon.png',
        'category': 'Non-living',
      },
      {
        'title': 'Computer',
        'letter': 'Cc',
        'image_asset': 'assets/flashcards/science/computer.png',
        'category': 'Non-living',
      },
      {
        'title': 'Car',
        'letter': 'Cc',
        'image_asset': 'assets/flashcards/science/car.png',
        'category': 'Non-living',
      },
    ];
    
    // Add descriptions based on age
    for (var item in [...livingThings, ...nonLivingThings]) {
      var title = item['title'] as String;
      var category = item['category'] as String;
      var description = '';
      
      // Age-specific descriptions
      if (age <= 4) {
        // Simple descriptions for younger children
        if (category == 'Living') {
          description = '$title are living things. They grow and need food and water.';
        } else {
          description = '$title are non-living things. They don\'t grow or need food.';
        }
      } else if (age == 5) {
        // More detailed for age 5
        if (category == 'Living') {
          switch (title) {
            case 'Plants':
              description = 'Plants are living things. They grow, need water, sunlight, and air to live.';
              break;
            case 'Animals':
              description = 'Animals are living things. They move, eat food, and breathe air.';
              break;
            case 'Humans':
              description = 'Humans are living things. We grow, eat food, and need water and air.';
              break;
            case 'Birds':
              description = 'Birds are living things. They have feathers, lay eggs, and can fly.';
              break;
            case 'Insects':
              description = 'Insects are small living things with six legs. They grow and change.';
              break;
          }
        } else {
          switch (title) {
            case 'Rocks':
              description = 'Rocks are non-living things. They don\'t grow or change on their own.';
              break;
            case 'Water':
              description = 'Water is a non-living thing. It flows and takes the shape of its container.';
              break;
            case 'Air':
              description = 'Air is a non-living thing that surrounds us. We need it to breathe.';
              break;
            case 'Toys':
              description = 'Toys are non-living things made by people. They don\'t grow or eat.';
              break;
            case 'Furniture':
              description = 'Furniture is non-living. Things like chairs and tables don\'t grow or change.';
              break;
          }
        }
      } else {
        // Most detailed for age 6
        if (category == 'Living') {
          switch (title) {
            case 'Plants':
              description = 'Plants are living organisms that can make their own food through photosynthesis. They grow, reproduce, and respond to their environment. Plants need water, sunlight, air, and nutrients to survive.';
              break;
            case 'Animals':
              description = 'Animals are living organisms that need to eat food to get energy. They can move, grow, reproduce, and respond to their environment. Different animals live in different habitats.';
              break;
            case 'Humans':
              description = 'Humans are living beings that belong to the animal kingdom. We grow, reproduce, and need food, water, and oxygen to survive. Humans have complex brains that help us think, learn, and create.';
              break;
            case 'Birds':
              description = 'Birds are living creatures with feathers, wings, and beaks. They lay eggs, build nests, and most can fly. Birds have hollow bones that help them stay light for flying.';
              break;
            case 'Insects':
              description = 'Insects are small living creatures with six legs and three body parts: head, thorax, and abdomen. Most have wings and antennae. Insects grow by molting - shedding their old exoskeleton as they grow.';
              break;
          }
        } else {
          switch (title) {
            case 'Rocks':
              description = 'Rocks are non-living objects made of minerals. They don\'t grow, breathe, or reproduce. Rocks can be formed by cooling lava, pressure on sediments, or changes to existing rocks.';
              break;
            case 'Water':
              description = 'Water is a non-living substance that covers most of Earth. It doesn\'t grow or reproduce, but it can change forms between solid (ice), liquid (water), and gas (water vapor).';
              break;
            case 'Air':
              description = 'Air is a non-living mixture of gases including oxygen, nitrogen, and carbon dioxide. It has no fixed shape or volume. Living things need the oxygen in air to survive.';
              break;
            case 'Toys':
              description = 'Toys are non-living objects made by people from materials like plastic, wood, or metal. They don\'t grow, eat, or reproduce. Toys need someone to move them - they can\'t move on their own.';
              break;
            case 'Furniture':
              description = 'Furniture consists of non-living objects made to support human activities. Unlike living things, furniture doesn\'t need food, water, or air. It\'s constructed from materials like wood, metal, or plastic.';
              break;
          }
        }
      }
      
      // Add description to item
      item['description'] = description;
      flashcards.add(item);
    }
    
    return flashcards.take(count).toList();
  }
  
  // Generate Emotions & Expressions flashcards with age-appropriate content
  static List<Map<String, dynamic>> _generateSharingCooperationFlashcards(
      String subject, int age, String language, int count) {
    List<Map<String, dynamic>> flashcards = [];
    
    // Basic sharing concepts for all ages
    final basicConcepts = [
      {
        'title': 'Taking Turns',
        'letter': 'Tt',
        'image_asset': 'assets/flashcards/social/taking_turns.png',
      },
      {
        'title': 'Sharing Toys',
        'letter': 'Ss',
        'image_asset': 'assets/flashcards/social/sharing_toys.png',
      },
      {
        'title': 'Helping Others',
        'letter': 'Hh',
        'image_asset': 'assets/flashcards/social/helping.png',
      },
      {
        'title': 'Listening',
        'letter': 'Ll',
        'image_asset': 'assets/flashcards/social/listening.png',
      },
      {
        'title': 'Being Kind',
        'letter': 'Kk',
        'image_asset': 'assets/flashcards/social/kindness.png',
      },
    ];
    
    // More advanced cooperation concepts for older children
    final advancedConcepts = [
      {
        'title': 'Teamwork',
        'letter': 'Tt',
        'image_asset': 'assets/flashcards/social/teamwork.png',
      },
      {
        'title': 'Apologizing',
        'letter': 'Aa',
        'image_asset': 'assets/flashcards/social/apologizing.png',
      },
      {
        'title': 'Patience',
        'letter': 'Pp',
        'image_asset': 'assets/flashcards/social/patience.png',
      },
      {
        'title': 'Empathy',
        'letter': 'Ee',
        'image_asset': 'assets/flashcards/social/empathy.png',
      },
      {
        'title': 'Problem Solving',
        'letter': 'Pp',
        'image_asset': 'assets/flashcards/social/problem_solving.png',
      },
    ];
    
    // Add descriptions based on age
    for (var card in basicConcepts) {
      var title = card['title'] as String;
      var description = '';
      
      // Age-specific descriptions
      if (age <= 4) {
        // Simple descriptions for younger children
        switch (title) {
          case 'Taking Turns':
            description = 'Wait for your turn, then others wait for theirs.';
            break;
          case 'Sharing Toys':
            description = 'Let friends play with your toys too.';
            break;
          case 'Helping Others':
            description = 'Do nice things to help your friends.';
            break;
          case 'Listening':
            description = 'Pay attention when others are talking.';
            break;
          case 'Being Kind':
            description = 'Say and do nice things for others.';
            break;
        }
      } else if (age == 5) {
        // More detailed for age 5
        switch (title) {
          case 'Taking Turns':
            description = 'Everyone gets a chance to play or speak. When it\'s not your turn, wait patiently.';
            break;
          case 'Sharing Toys':
            description = 'Let others play with your toys. Sharing makes playtime fun for everyone.';
            break;
          case 'Helping Others':
            description = 'When someone needs help, try to assist them. Helping makes others happy.';
            break;
          case 'Listening':
            description = 'Look at the person who is talking and think about what they say.';
            break;
          case 'Being Kind':
            description = 'Use nice words and do helpful things. Kindness makes everyone feel good.';
            break;
        }
      } else {
        // Most detailed for age 6
        switch (title) {
          case 'Taking Turns':
            description = 'Taking turns means everyone gets a fair chance to participate. It\'s an important part of playing games and having conversations.';
            break;
          case 'Sharing Toys':
            description = 'Sharing means letting others use things that belong to you.';
            break;
          case 'Helping Others':
            description = 'Helping others means offering assistance when someone needs it.';
            break;
          case 'Listening':
            description = 'Active listening means paying full attention when others speak.';
            break;
          case 'Being Kind':
            description = 'Kindness means doing and saying things that make others feel good.';
            break;
        }
      }
      
      // Add description to card
      card['description'] = description;
      flashcards.add(card);
    }
    
    // Add advanced concepts for older children
    if (age >= 5) {
      for (var card in advancedConcepts.take(age == 5 ? 2 : 5)) {
        var title = card['title'] as String;
        var description = '';
        
        if (age == 5) {
          // Simpler descriptions for age 5
          switch (title) {
            case 'Teamwork':
              description = 'Working together to get something done.';
              break;
            case 'Apologizing':
              description = 'Saying sorry when you make a mistake.';
              break;
          }
        } else {
          // More detailed for age 6
          switch (title) {
            case 'Teamwork':
              description = 'Teamwork means working together toward a common goal. When we work as a team, we can accomplish more than we could alone. Everyone contributes their skills and ideas.';
              break;
            case 'Apologizing':
              description = 'Apologizing means saying sorry when we\'ve done something wrong. A good apology shows we understand what we did wrong and will try not to do it again.';
              break;
            case 'Patience':
              description = 'Patience means waiting calmly without getting upset. Being patient helps us handle delays and gives others the time they need to learn or complete tasks.';
              break;
            case 'Empathy':
              description = 'Empathy means understanding how another person feels. When we show empathy, we try to imagine what it\'s like to be in someone else\'s situation.';
              break;
            case 'Problem Solving':
              description = 'Problem solving means finding good solutions when there\'s a difficulty. It involves thinking about what\'s happening, talking about ideas, and trying solutions.';
              break;
          }
        }
        
        // Add description to card
        card['description'] = description;
        flashcards.add(card);
      }
    }
    
    return flashcards.take(count).toList();
  }
  
  static List<Map<String, dynamic>> _generateEmotionsFlashcards(
      String subject, int age, String language, int count) {
    List<Map<String, dynamic>> flashcards = [];
    
    // Basic emotions for all ages
    final basicEmotions = [
      {
        'title': 'Happy',
        'letter': 'Hh',
        'image_asset': 'assets/flashcards/emotions/happy.png',
      },
      {
        'title': 'Sad',
        'letter': 'Ss',
        'image_asset': 'assets/flashcards/emotions/sad.png',
      },
      {
        'title': 'Angry',
        'letter': 'Aa',
        'image_asset': 'assets/flashcards/emotions/angry.png',
      },
      {
        'title': 'Scared',
        'letter': 'Ss',
        'image_asset': 'assets/flashcards/emotions/scared.png',
      },
      {
        'title': 'Excited',
        'letter': 'Ee',
        'image_asset': 'assets/flashcards/emotions/excited.png',
      },
    ];
    
    // More complex emotions for older children
    final complexEmotions = [
      {
        'title': 'Proud',
        'letter': 'Pp',
        'image_asset': 'assets/flashcards/emotions/proud.png',
      },
      {
        'title': 'Surprised',
        'letter': 'Ss',
        'image_asset': 'assets/flashcards/emotions/surprised.png',
      },
      {
        'title': 'Confused',
        'letter': 'Cc',
        'image_asset': 'assets/flashcards/emotions/confused.png',
      },
      {
        'title': 'Calm',
        'letter': 'Cc',
        'image_asset': 'assets/flashcards/emotions/calm.png',
      },
      {
        'title': 'Frustrated',
        'letter': 'Ff',
        'image_asset': 'assets/flashcards/emotions/frustrated.png',
      },
    ];
    
    // Add descriptions based on age
    for (var card in basicEmotions) {
      var title = card['title'] as String;
      var description = '';
      
      // Age-specific descriptions
      if (age <= 4) {
        // Simple descriptions for younger children
        switch (title) {
          case 'Happy':
            description = 'When we smile and feel good.';
            break;
          case 'Sad':
            description = 'When we feel upset and might cry.';
            break;
          case 'Angry':
            description = 'When we feel mad about something.';
            break;
          case 'Scared':
            description = 'When we feel afraid of something.';
            break;
          case 'Excited':
            description = 'When we feel really happy about something new.';
            break;
        }
      } else if (age == 5) {
        // More detailed for age 5
        switch (title) {
          case 'Happy':
            description = 'When we feel good inside and smile. We feel happy when good things happen.';
            break;
          case 'Sad':
            description = 'When we feel down and might cry. We feel sad when something bad happens.';
            break;
          case 'Angry':
            description = 'When we feel upset and mad. Our face might get red and we want to yell.';
            break;
          case 'Scared':
            description = 'When we feel afraid of something. Our heart beats fast and we might hide.';
            break;
          case 'Excited':
            description = 'When we feel really happy and can\'t wait for something. We might jump or clap.';
            break;
        }
      } else {
        // Most detailed for age 6
        switch (title) {
          case 'Happy':
            description = 'Happiness is a feeling of joy and contentment. When we\'re happy, we smile, laugh, and feel good inside. Many things can make us happy like playing with friends or doing something we enjoy.';
            break;
          case 'Sad':
            description = 'Sadness is a feeling we get when something bad happens. When we\'re sad, we might cry or want to be alone. It\'s okay to feel sad sometimes, and talking about our feelings can help us feel better.';
            break;
          case 'Angry':
            description = 'Anger is a strong feeling we get when something unfair happens. When we\'re angry, our face might get red and we might want to yell. Taking deep breaths can help us calm down.';
            break;
          case 'Scared':
            description = 'Fear is what we feel when we think something might hurt us. When we\'re scared, our heart beats fast and we want to run away or hide. Being scared helps keep us safe from danger.';
            break;
          case 'Excited':
            description = 'Excitement is a happy, energetic feeling we get when we\'re looking forward to something good. When we\'re excited, we might feel butterflies in our stomach and have more energy.';
            break;
        }
      }
      
      // Add description to card
      card['description'] = description;
      flashcards.add(card);
    }
    
    // Add complex emotions for older children
    if (age >= 5) {
      for (var card in complexEmotions.take(age == 5 ? 3 : 5)) { // Fewer complex emotions for age 5
        var title = card['title'] as String;
        var description = '';
        
        // Age-specific descriptions
        if (age == 5) {
          switch (title) {
            case 'Proud':
              description = 'When we feel good about something we did well.';
              break;
            case 'Surprised':
              description = 'When something unexpected happens and our eyes get big.';
              break;
            case 'Confused':
              description = 'When we don\'t understand something and need help.';
              break;
          }
        } else {
          // For age 6
          switch (title) {
            case 'Proud':
              description = 'Pride is a good feeling we get when we accomplish something difficult. When we feel proud, we stand tall and want to show others what we\'ve done.';
              break;
            case 'Surprised':
              description = 'Surprise is what we feel when something unexpected happens. When we\'re surprised, our eyes get wide and we might gasp.';
              break;
            case 'Confused':
              description = 'Confusion happens when we don\'t understand something. When we\'re confused, we might ask questions to help us understand better.';
              break;
            case 'Calm':
              description = 'Calmness is a peaceful feeling when we\'re relaxed. When we\'re calm, our breathing is slow and our mind feels quiet.';
              break;
            case 'Frustrated':
              description = 'Frustration is what we feel when we try to do something but keep having problems. When we\'re frustrated, taking a break can help us try again.';
              break;
          }
        }
        
        // Add description to card
        card['description'] = description;
        flashcards.add(card);
      }
    }
    
    return flashcards.take(count).toList();
  }
  
  // Generate Color Exploration & Mixing flashcards with age-appropriate content
  static List<Map<String, dynamic>> _generateColorExplorationFlashcards(
      String subject, int age, String language, int count) {
    List<Map<String, dynamic>> flashcards = [];
    
    // Basic colors for all ages
    final basicColors = [
      {
        'title': 'Red',
        'letter': 'Rr',
        'image_asset': 'assets/flashcards/colors/red.png',
        'color_code': '#FF0000',
      },
      {
        'title': 'Blue',
        'letter': 'Bb',
        'image_asset': 'assets/flashcards/colors/blue.png',
        'color_code': '#0000FF',
      },
      {
        'title': 'Yellow',
        'letter': 'Yy',
        'image_asset': 'assets/flashcards/colors/yellow.png',
        'color_code': '#FFFF00',
      },
      {
        'title': 'Green',
        'letter': 'Gg',
        'image_asset': 'assets/flashcards/colors/green.png',
        'color_code': '#00FF00',
      },
      {
        'title': 'Orange',
        'letter': 'Oo',
        'image_asset': 'assets/flashcards/colors/orange.png',
        'color_code': '#FFA500',
      },
    ];
    
    // Additional colors for older children
    final advancedColors = [
      {
        'title': 'Purple',
        'letter': 'Pp',
        'image_asset': 'assets/flashcards/colors/purple.png',
        'color_code': '#800080',
      },
      {
        'title': 'Pink',
        'letter': 'Pp',
        'image_asset': 'assets/flashcards/colors/pink.png',
        'color_code': '#FFC0CB',
      },
      {
        'title': 'Brown',
        'letter': 'Bb',
        'image_asset': 'assets/flashcards/colors/brown.png',
        'color_code': '#A52A2A',
      },
      {
        'title': 'Black',
        'letter': 'Bb',
        'image_asset': 'assets/flashcards/colors/black.png',
        'color_code': '#000000',
      },
      {
        'title': 'White',
        'letter': 'Ww',
        'image_asset': 'assets/flashcards/colors/white.png',
        'color_code': '#FFFFFF',
      },
    ];
    
    // Add descriptions based on age
    for (var card in basicColors) {
      var title = card['title'] as String;
      var description = '';
      
      // Age-specific descriptions
      if (age <= 4) {
        // Simple descriptions for younger children
        switch (title) {
          case 'Red':
            description = 'Red like an apple.';
            break;
          case 'Blue':
            description = 'Blue like the sky.';
            break;
          case 'Yellow':
            description = 'Yellow like the sun.';
            break;
          case 'Green':
            description = 'Green like grass.';
            break;
          case 'Orange':
            description = 'Orange like an orange fruit.';
            break;
        }
      } else if (age == 5) {
        // More detailed for age 5
        switch (title) {
          case 'Red':
            description = 'Red is a bright color like apples, strawberries, and fire trucks.';
            break;
          case 'Blue':
            description = 'Blue is the color of the sky and ocean. It can be light or dark.';
            break;
          case 'Yellow':
            description = 'Yellow is a sunny color like bananas, lemons, and the sun.';
            break;
          case 'Green':
            description = 'Green is the color of grass, leaves, and many vegetables.';
            break;
          case 'Orange':
            description = 'Orange is a mix of red and yellow, like oranges and carrots.';
            break;
        }
      } else {
        // Most detailed for age 6
        switch (title) {
          case 'Red':
            description = 'Red is a primary color. It can be found in nature in apples, roses, and ladybugs. Red can express strong feelings like love or anger. Red and yellow mixed together make orange.';
            break;
          case 'Blue':
            description = 'Blue is a primary color. It\'s the color of the sky and ocean. Blue often makes people feel calm and peaceful. Blue and yellow mixed together make green.';
            break;
          case 'Yellow':
            description = 'Yellow is a primary color. It\'s bright like the sun and often makes people feel happy and cheerful. Yellow and blue mixed together make green.';
            break;
          case 'Green':
            description = 'Green is a secondary color made by mixing blue and yellow. It\'s the color of plants, leaves, and grass. Green reminds us of nature and growth.';
            break;
          case 'Orange':
            description = 'Orange is a secondary color made by mixing red and yellow. It\'s a warm color like autumn leaves, oranges, and pumpkins. Orange is energetic and exciting.';
            break;
        }
      }
      
      // Add description to card
      card['description'] = description;
      flashcards.add(card);
    }
    
    // Add advanced colors for older children
    if (age >= 5) {
      for (var card in advancedColors.take(age == 5 ? 2 : 5)) { // Fewer complex emotions for age 5
        var title = card['title'] as String;
        var description = '';
        
        if (age == 5) {
          // Simpler descriptions for age 5
          switch (title) {
            case 'Purple':
              description = 'Purple is a mix of red and blue, like grapes and some flowers.';
              break;
            case 'Pink':
              description = 'Pink is a light red color like cotton candy and cherry blossoms.';
              break;
          }
        } else {
          // More detailed for age 6
          switch (title) {
            case 'Purple':
              description = 'Purple is a secondary color made by mixing red and blue. It can be light like lavender or dark like eggplants. Purple was once a color worn by kings and queens.';
              break;
            case 'Pink':
              description = 'Pink is made by adding white to red. It comes in many shades from light pink like cherry blossoms to bright pink like flamingos. Pink is often associated with sweetness and kindness.';
              break;
            case 'Brown':
              description = 'Brown is made by mixing different colors together like red, yellow, and black. It\'s the color of soil, tree trunks, and chocolate. Brown is a natural, earthy color.';
              break;
            case 'Black':
              description = 'Black is the absence of color. It absorbs all light instead of reflecting it. Black can make other colors stand out when placed next to them. It\'s the color of night sky.';
              break;
            case 'White':
              description = 'White reflects all colors of light. It makes colors lighter when mixed with them to create tints. White is associated with cleanliness and simplicity.';
              break;
          }
        }
        
        // Add description to card
        card['description'] = description;
        flashcards.add(card);
      }
    }
    
    return flashcards.take(count).toList();
  }
  
  // Generate Lines & Patterns flashcards with age-appropriate content
  static List<Map<String, dynamic>> _generateLinesAndPatternsFlashcards(
      String subject, int age, String language, int count) {
    List<Map<String, dynamic>> flashcards = [];
    
    // Basic lines and patterns for all ages
    final basicPatterns = [
      {
        'title': 'Straight Line',
        'letter': 'Ll',
        'image_asset': 'assets/flashcards/patterns/straight_line.png',
      },
      {
        'title': 'Curved Line',
        'letter': 'Cc',
        'image_asset': 'assets/flashcards/patterns/curved_line.png',
      },
      {
        'title': 'Zigzag',
        'letter': 'Zz',
        'image_asset': 'assets/flashcards/patterns/zigzag.png',
      },
      {
        'title': 'Spiral',
        'letter': 'Ss',
        'image_asset': 'assets/flashcards/patterns/spiral.png',
      },
      {
        'title': 'Circle Pattern',
        'letter': 'Cc',
        'image_asset': 'assets/flashcards/patterns/circle_pattern.png',
      },
    ];
    
    // Advanced patterns for older children
    final advancedPatterns = [
      {
        'title': 'Checkered Pattern',
        'letter': 'Cc',
        'image_asset': 'assets/flashcards/patterns/checkered.png',
      },
      {
        'title': 'Stripes',
        'letter': 'Ss',
        'image_asset': 'assets/flashcards/patterns/stripes.png',
      },
      {
        'title': 'Polka Dots',
        'letter': 'Pp',
        'image_asset': 'assets/flashcards/patterns/polka_dots.png',
      },
      {
        'title': 'Symmetry',
        'letter': 'Ss',
        'image_asset': 'assets/flashcards/patterns/symmetry.png',
      },
      {
        'title': 'Repeating Pattern',
        'letter': 'Rr',
        'image_asset': 'assets/flashcards/patterns/repeating.png',
      },
    ];
    
    // Add descriptions based on age
    for (var card in basicPatterns) {
      var title = card['title'] as String;
      var description = '';
      
      // Age-specific descriptions
      if (age <= 4) {
        // Simple descriptions for younger children
        switch (title) {
          case 'Straight Line':
            description = 'A line that goes from one point to another without curves.';
            break;
          case 'Curved Line':
            description = 'A line that bends like a rainbow.';
            break;
          case 'Zigzag':
            description = 'A line that goes up and down with sharp corners.';
            break;
          case 'Spiral':
            description = 'A line that curves around and around getting bigger or smaller.';
            break;
          case 'Circle Pattern':
            description = 'Many circles arranged together to make a design.';
            break;
        }
      } else if (age == 5) {
        // More detailed for age 5
        switch (title) {
          case 'Straight Line':
            description = 'A straight line is the shortest path between two points. You can draw horizontal, vertical, or diagonal straight lines.';
            break;
          case 'Curved Line':
            description = 'A curved line bends smoothly without sharp corners. Curved lines can make shapes like waves, hills, or arches.';
            break;
          case 'Zigzag':
            description = 'A zigzag is made of straight lines that change direction with sharp angles. It looks like lightning or mountain peaks.';
            break;
          case 'Spiral':
            description = 'A spiral is a curved line that winds around a center point, getting farther away or closer to the center as it goes.';
            break;
          case 'Circle Pattern':
            description = 'Circle patterns use many circles arranged in different ways. The circles can be different sizes and sometimes overlap.';
            break;
        }
      } else {
        // Most detailed for age 6
        switch (title) {
          case 'Straight Line':
            description = 'A straight line is a path that doesn\'t curve or bend. Lines can be horizontal (flat like the horizon), vertical (up and down like a flagpole), or diagonal (slanted). Straight lines are used in many designs and structures.';
            break;
          case 'Curved Line':
            description = 'A curved line changes direction smoothly without sharp angles. Curves can be gentle or dramatic, and they create flowing, dynamic compositions. In nature, we see curved lines in rivers, hills, and many plants.';
            break;
          case 'Zigzag':
            description = 'A zigzag pattern consists of connected lines that form sharp angles as they change direction. Zigzags create a sense of energy and movement in artwork. We can see zigzags in lightning bolts, mountain ranges, and many decorative patterns.';
            break;
          case 'Spiral':
            description = 'A spiral is a curved line that winds around a central point, moving closer to or farther from the center. Spirals appear in nature in snail shells, some plants, and even in huge galaxy formations in space.';
            break;
          case 'Circle Pattern':
            description = 'Circle patterns use circles as repeating elements in a design. Artists can vary the size, spacing, color, and arrangement of circles to create different effects. Circle patterns can be simple or complex and are found in many cultures\' art and design.';
            break;
        }
      }
      
      // Add description to card
      card['description'] = description;
      flashcards.add(card);
    }
    
    // Add advanced patterns for older children
    if (age >= 5) {
      for (var card in advancedPatterns.take(age == 5 ? 2 : 5)) {
        var title = card['title'] as String;
        var description = '';
        
        if (age == 5) {
          // Simpler descriptions for age 5
          switch (title) {
            case 'Checkered Pattern':
              description = 'A pattern of squares in two colors arranged like a checkerboard game.';
              break;
            case 'Stripes':
              description = 'Lines of color next to each other, like on a zebra or tiger.';
              break;
          }
        } else {
          // More detailed for age 6
          switch (title) {
            case 'Checkered Pattern':
              description = 'A checkered pattern alternates squares of two colors in rows and columns, like a chess or checkers board. This pattern creates a strong visual contrast and is used in many types of designs, from floors to clothing.';
              break;
            case 'Stripes':
              description = 'Stripes are parallel lines of different colors or textures. They can be vertical, horizontal, or diagonal. Stripes can be different widths and can create various visual effects depending on their arrangement and colors.';
              break;
            case 'Polka Dots':
              description = 'Polka dots are a pattern of equally sized dots arranged in a regular grid. The dots are usually evenly spaced on a contrasting background. This pattern is playful and has been popular in fashion and design for many years.';
              break;
            case 'Symmetry':
              description = 'Symmetry happens when one half of a design mirrors the other half. If you draw a line down the middle, both sides match. Butterflies, human faces, and many flowers show symmetry in nature.';
              break;
            case 'Repeating Pattern':
              description = 'A repeating pattern uses the same element or group of elements over and over in a regular way. The repeated elements can be simple shapes or complex designs. Many fabrics, wallpapers, and decorations use repeating patterns.';
              break;
          }
        }
        
        // Add description to card
        card['description'] = description;
        flashcards.add(card);
      }
    }
    
    return flashcards.take(count).toList();
  }
  
  // Generate default flashcards when no specific template is available
  static List<Map<String, dynamic>> _generateDefaultFlashcards(
      String subject, int age, String language, int count) {
    List<Map<String, dynamic>> flashcards = [];
    
    // Create generic flashcards based on subject
    final String normalizedSubject = subject.toLowerCase().trim();
    
    if (normalizedSubject.contains('english')) {
      // Default to English alphabet if subject is related to English
      return _generateEnglishAlphabetFlashcards(subject, age, language, count);
    } else if (normalizedSubject.contains('bahasa') || normalizedSubject.contains('malay')) {
      // Default to Malay letters if subject is related to Bahasa Malaysia
      return _generateMalayLettersFlashcards(subject, age, language, count);
    } else if (normalizedSubject.contains('math') || normalizedSubject.contains('matematik')) {
      // Default to counting if subject is related to Math
      return _generateCountingFlashcards(subject, age, language, count);
    } else if (normalizedSubject.contains('jawi')) {
      // Default to Jawi letters if subject is related to Jawi
      return _generateJawiLettersFlashcards(subject, age, language, count);
    } else if (normalizedSubject.contains('iqraa') || normalizedSubject.contains('hijaiyah')) {
      // Default to Hijaiyah letters if subject is related to Iqraa/Arabic
      return _generateHijaiyahLettersFlashcards(subject, age, language, count);
    } else {
      // Generic flashcards for any subject
      List<Map<String, dynamic>> genericFlashcards = [
        {
          'title': 'Learning $subject',
          'letter': subject.isNotEmpty ? subject[0].toUpperCase() + subject[0].toLowerCase() : 'Aa',
          'image_asset': 'assets/flashcards/generic/learning.png',
          'description': 'Let\'s learn about $subject together!',
        },
        {
          'title': 'Exploring',
          'letter': 'Ee',
          'image_asset': 'assets/flashcards/generic/exploring.png',
          'description': 'Exploring new things helps us learn and grow.',
        },
        {
          'title': 'Discovery',
          'letter': 'Dd',
          'image_asset': 'assets/flashcards/generic/discovery.png',
          'description': 'Discovering new ideas is exciting!',
        },
        {
          'title': 'Knowledge',
          'letter': 'Kk',
          'image_asset': 'assets/flashcards/generic/knowledge.png',
          'description': 'Knowledge helps us understand the world better.',
        },
        {
          'title': 'Questions',
          'letter': 'Qq',
          'image_asset': 'assets/flashcards/generic/questions.png',
          'description': 'Asking questions helps us learn more.',
        },
      ];
      
      return genericFlashcards.take(count).toList();
    }
  }
}
