class Activity {
  final String id;
  final String label;
  final String imagePath;

  const Activity({
    required this.id,
    required this.label,
    required this.imagePath,
  });

  static const List<Activity> all = [
    Activity(id: 'swing',        label: 'Swing',          imagePath: 'lib/Assets/IMG_6900.jpg'),
    Activity(id: 'bathroom',     label: 'Bathroom',       imagePath: 'lib/Assets/IMG_6901.jpg'),
    Activity(id: 'video',        label: 'Video',          imagePath: 'lib/Assets/IMG_6902.jpg'),
    Activity(id: 'spaceroom',    label: 'Space Room',     imagePath: 'lib/Assets/IMG_6903.jpg'),
    Activity(id: 'city',         label: 'City',           imagePath: 'lib/Assets/IMG_6904.jpg'),
    Activity(id: 'junglegym',    label: 'Jungle Gym',     imagePath: 'lib/Assets/IMG_6905.jpg'),
    Activity(id: 'circle',       label: 'Circle',         imagePath: 'lib/Assets/IMG_6906.jpg'),
    Activity(id: 'eat',          label: 'Eat',            imagePath: 'lib/Assets/IMG_6907.jpg'),
    Activity(id: 'table',        label: 'Table Time',     imagePath: 'lib/Assets/IMG_6908.jpg'),
    Activity(id: 'freeplay',     label: 'Play',           imagePath: 'lib/Assets/IMG_6909.jpg'),
    Activity(id: 'ball',         label: 'Ball',           imagePath: 'lib/Assets/IMG_6910.jpg'),
    Activity(id: 'carramp',      label: 'Car Ramp',       imagePath: 'lib/Assets/IMG_6911.jpg'),
    Activity(id: 'books',        label: 'Read',           imagePath: 'lib/Assets/IMG_6912.jpg'),
    Activity(id: 'bubbles',      label: 'Bubbles',        imagePath: 'lib/Assets/IMG_6913.jpg'),
    Activity(id: 'diaper',       label: 'Diaper Change',  imagePath: 'lib/Assets/IMG_6914.jpg'),
    Activity(id: 'outside',      label: 'Outside',        imagePath: 'lib/Assets/IMG_6915.jpg'),
    Activity(id: 'trampoline',   label: 'Trampoline',     imagePath: 'lib/Assets/IMG_6916.jpg'),
    Activity(id: 'throwaway',    label: 'Throw Away',     imagePath: 'lib/Assets/IMG_6917.jpg'),
    Activity(id: 'library',      label: 'Library',        imagePath: 'lib/Assets/IMG_6918.jpg'),
    Activity(id: 'toysincity',   label: 'Toys in City',   imagePath: 'lib/Assets/IMG_6919.jpg'),
    Activity(id: 'playtoys',     label: 'Play',           imagePath: 'lib/Assets/IMG_6920.jpg'),
    Activity(id: 'sit',          label: 'Sit',            imagePath: 'lib/Assets/IMG_6921.jpg'),
    Activity(id: 'playdough',    label: 'Play Doh',       imagePath: 'lib/Assets/IMG_6922.jpg'),
    Activity(id: 'puzzle',       label: 'Puzzle',         imagePath: 'lib/Assets/IMG_6923.jpg'),
    Activity(id: 'balls',        label: 'Balls',          imagePath: 'lib/Assets/IMG_6924.jpg'),
    Activity(id: 'slide',        label: 'Slide',          imagePath: 'lib/Assets/IMG_6925.jpg'),
    Activity(id: 'walk',         label: 'Walk Together',  imagePath: 'lib/Assets/IMG_6926.jpg'),
    Activity(id: 'cleanup',      label: 'Clean Up',       imagePath: 'lib/Assets/IMG_6927.jpg'),
    Activity(id: 'coloring',     label: 'Coloring',       imagePath: 'lib/Assets/IMG_6928.jpg'),
    Activity(id: 'ocean',        label: 'Ocean',          imagePath: 'lib/Assets/IMG_6929.jpg'),
    Activity(id: 'ballpit',      label: 'Ball Pit',       imagePath: 'lib/Assets/IMG_6930.jpg'),
  ];
}
