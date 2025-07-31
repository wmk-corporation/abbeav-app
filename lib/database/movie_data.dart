import 'package:abbeav/models/actor_model.dart';
import 'package:abbeav/models/movie_model.dart';

class MovieData {
  static List<MovieModel> movies = [
    MovieModel('assets/images/carousel/mv_02.png',
        name: 'Elephant', duration: '1h 30m', rating: '4.3'),
    MovieModel('assets/images/carousel/mv_01.jpg',
        name: 'Big Buck Bunny', duration: '10m', rating: '4.7'),
    MovieModel('assets/images/carousel/mv_03.jpg',
        name: 'Lab Rat', duration: '18m', rating: '4.1'),
  ];

  static List<MovieModel> movies2 = [
    MovieModel('assets/images/poster8.jpg',
        name: 'Furie', duration: '1h 38m', rating: '4.0'),
    MovieModel('assets/images/poster6.jpg',
        name: 'Joker', duration: '2h 2m', rating: '4.2'),
    MovieModel('assets/images/poster7.jpg',
        name: 'Leo', duration: '2h 44m', rating: '7.2'),
  ];

  static List<MovieModel> movies3 = [
    MovieModel(
      'assets/images/search/mv_02.png',
      name: 'Elephant',
      duration: '1h 30m',
      rating: '4.3',
    ),
    MovieModel(
      'assets/images/search/mv_01.jpg',
      name: 'Big Buck Bunny',
      duration: '10m',
      rating: '4.7',
    ),
    MovieModel(
      'assets/images/search/mv_03.jpg',
      name: 'Lab Rat',
      duration: '18m',
      rating: '4.1',
    ),
    MovieModel(
      'assets/images/search/mv_04.jpg',
      name: 'Automata',
      duration: '1h 49m',
      rating: '4.0',
    ),
    MovieModel(
      'assets/images/search/mv_05.png',
      name: 'Jordan Mosley',
      duration: '1h 12m',
      rating: '3.8',
    ),
    MovieModel(
      'assets/images/search/mv_06.png',
      name: 'Figment',
      duration: '1h 05m',
      rating: '4.4',
    ),
  ];

  // Nouvelle liste pour le carousel avec toutes les infos détaillées
  /*static List<MovieCarouselModel> moviesCarousel = [
    MovieCarouselModel(
      name: 'A Quiet Place 2',
      image: 'assets/images/poster4.jpg',
      description:
          "Après les événements mortels à la maison, la famille Abbott doit maintenant affronter les terreurs du monde extérieur. Forcés de s’aventurer dans l’inconnu, ils réalisent que les créatures qui chassent au son ne sont pas la seule menace.",
      genres: ['Horreur', 'Thriller', 'Science-fiction'],
      rating: 4.2,
      season: null,
      releaseDate: '2021-05-28',
      duration: '1h 37m',
      director: 'John Krasinski',
      actors: ['Emily Blunt', 'Cillian Murphy', 'Millicent Simmonds'],
      language: 'Anglais',
      country: 'USA',
    ),
    MovieCarouselModel(
      name: 'Vikkin',
      image: 'assets/images/poster3.png',
      description:
          "Barry Allen, un scientifique de la police, devient le super-héros le plus rapide du monde. Il utilise ses pouvoirs pour combattre le crime et voyager dans le temps afin de sauver sa famille et l’univers.",
      genres: ['Action', 'Aventure', 'Science-fiction', 'Série'],
      rating: 4.0,
      season: 8,
      releaseDate: '2014-10-07',
      duration: '8 saisons',
      director: 'Greg Berlanti',
      actors: ['Grant Gustin', 'Candice Patton', 'Danielle Panabaker'],
      language: 'Anglais',
      country: 'USA',
    ),
    MovieCarouselModel(
      name: 'Money Heist',
      image: 'assets/images/poster5.jpg',
      description:
          "Un mystérieux homme surnommé 'Le Professeur' planifie le plus grand braquage jamais réalisé en Espagne. Huit criminels recrutés pour leurs compétences uniques prennent des otages à la Fabrique nationale de la monnaie.",
      genres: ['Crime', 'Drame', 'Thriller', 'Série'],
      rating: 8.2,
      season: 5,
      releaseDate: '2017-05-02',
      duration: '5 saisons',
      director: 'Álex Pina',
      actors: ['Úrsula Corberó', 'Álvaro Morte', 'Itziar Ituño'],
      language: 'Espagnol',
      country: 'Espagne',
    ),
  ];*/

  /*static List<MovieCarouselModel> moviesCarousel = [
    MovieCarouselModel(
      name: 'Mulan',
      image: 'assets/images/poster4.jpg',
      description:
          "To save her ailing father, Mulan disguises herself as a man and joins the imperial army. She must embrace her strength and courage to defend China against northern invaders.",
      genres: ['Action', 'Adventure', 'Drama'],
      rating: 4.5,
      season: null,
      releaseDate: '2020-09-04',
      duration: '1h 55m',
      director: 'Niki Caro',
      actors: ['Liu Yifei', 'Donnie Yen', 'Jet Li'],
      language: 'English',
      country: 'USA',
    ),
    MovieCarouselModel(
      name: 'Vikings',
      image: 'assets/images/poster3.png',
      description:
          "Follow the legendary Viking chieftain Ragnar Lothbrok as he rises to become king of the Viking tribes. A tale of exploration, conquest, and betrayal set in medieval Scandinavia.",
      genres: ['Action', 'Drama', 'History', 'TV Series'],
      rating: 4.6,
      season: 6,
      releaseDate: '2013-03-03',
      duration: '6 seasons',
      director: 'Michael Hirst',
      actors: ['Travis Fimmel', 'Katheryn Winnick', 'Clive Standen'],
      language: 'English',
      country: 'Canada/Ireland',
    ),
    MovieCarouselModel(
      name: 'The Flash',
      image: 'assets/images/poster5.jpg',
      description:
          "Barry Allen, a police forensic scientist, becomes the fastest man alive. As The Flash, he uses his super-speed to fight criminals, travel through time, and protect the multiverse.",
      genres: ['Action', 'Adventure', 'Sci-Fi', 'TV Series'],
      rating: 4.0,
      season: 8,
      releaseDate: '2014-10-07',
      duration: '8 seasons',
      director: 'Greg Berlanti',
      actors: ['Grant Gustin', 'Candice Patton', 'Danielle Panabaker'],
      language: 'English',
      country: 'USA',
    ),
  ];*/

  static List<MovieCarouselModel> moviesCarousel = [
    MovieCarouselModel(
      name: 'Elephant',
      image: 'assets/images/carousel/mv_02.png',
      description:
          "A silent journey through the African savanna, where a young elephant leads his herd across the harsh landscape in search of water and safety.",
      genres: ['Documentary', 'Drama', 'Nature'],
      rating: 4.3,
      season: null,
      releaseDate: '2021-04-22',
      duration: '1h 30m',
      director: 'Mark Linfield',
      actors: ['Narrated by Meghan Markle'],
      language: 'English',
      country: 'UK',
    ),
    MovieCarouselModel(
      name: 'Big Buck Bunny',
      image: 'assets/images/carousel/mv_01.jpg',
      description:
          "A giant, gentle rabbit seeks peace in a sunny meadow, but a trio of troublemakers push him too far — leading to a hilarious tale of furry revenge.",
      genres: ['Animation', 'Comedy', 'Family'],
      rating: 4.7,
      season: null,
      releaseDate: '2008-05-19',
      duration: '10m',
      director: 'Sacha Goedegebure',
      actors: ['Big Buck Bunny', 'Frank the Flying Squirrel'],
      language: 'English',
      country: 'Netherlands',
    ),
    MovieCarouselModel(
      name: 'Skin',
      image: 'assets/images/carousel/mv_03.jpg',
      description:
          "In a high-tech underground lab, a rogue AI conducts bizarre experiments on a group of lab animals, until one rat fights back to escape the system.",
      genres: ['Sci-Fi', 'Thriller', 'Short'],
      rating: 4.1,
      season: null,
      releaseDate: '2022-10-13',
      duration: '18m',
      director: 'Kara Freeman',
      actors: ['Voice of John Cho', 'Voice of Emily Blunt'],
      language: 'English',
      country: 'USA',
    ),
  ];

  static List<ActorModel> actors = [
    ActorModel(image: 'assets/images/actors/act_01.jpg', name: 'Robert Downey'),
    ActorModel(
        image: 'assets/images/actors/act_02.jpg', name: 'Samuel l jackson'),
    ActorModel(image: 'assets/images/actors/act_03.png', name: 'Emma watson'),
    ActorModel(image: 'assets/images/actors/act_04.png', name: 'Margot robbie'),
  ];
}

// Modèle pour le carousel avec toutes les infos nécessaires
class MovieCarouselModel {
  final String name;
  final String image;
  final String description;
  final List<String> genres;
  final double rating;
  final int? season;
  final String releaseDate;
  final String duration;
  final String director;
  final List<String> actors;
  final String language;
  final String country;

  MovieCarouselModel({
    required this.name,
    required this.image,
    required this.description,
    required this.genres,
    required this.rating,
    this.season,
    required this.releaseDate,
    required this.duration,
    required this.director,
    required this.actors,
    required this.language,
    required this.country,
  });
}

/*import 'package:abbeav/models/actor_model.dart';
import 'package:abbeav/models/movie_model.dart';

class MovieData {
  static List<MovieModel> movies = [
    MovieModel('assets/images/poster4.jpg',
        name: 'A Quiet Place 2', duration: '1h 37m', rating: '4.2'),
    MovieModel('assets/images/poster3.png',
        name: 'The Flash', duration: '8 seasons', rating: '4.0'),
    MovieModel('assets/images/poster5.jpg',
        name: 'Money Heist', duration: '5 seasons', rating: '8.2'),
  ];
  static List<MovieModel> movies2 = [
    MovieModel('assets/images/poster8.jpg',
        name: 'Furie', duration: '1h 38m', rating: '4.0'),
    MovieModel('assets/images/poster6.jpg',
        name: 'Joker', duration: '2h 2m', rating: '4.2'),
    MovieModel('assets/images/poster7.jpg',
        name: 'Leo', duration: '2h 44m', rating: '7.2'),
  ];
  static List<MovieModel> movies3 = [
    MovieModel('assets/images/poster4.jpg',
        name: 'A Quiet Place 2', duration: '1h 37m', rating: '4.2'),
    MovieModel('assets/images/poster3.png',
        name: 'The Flash', duration: '8 seasons', rating: '4.0'),
    MovieModel('assets/images/poster5.jpg',
        name: 'Money Heist', duration: '5 seasons', rating: '8.2'),
    MovieModel('assets/images/poster8.jpg',
        name: 'Furie', duration: '1h 38m', rating: '4.0'),
    MovieModel('assets/images/poster6.jpg',
        name: 'Joker', duration: '2h 2m', rating: '4.2'),
    MovieModel('assets/images/poster7.jpg',
        name: 'Leo', duration: '2h 44m', rating: '7.2'),
  ];

  static List<ActorModel> actors = [
    ActorModel(image: 'assets/images/actor1.jpg', name: 'Robert Downey'),
    ActorModel(image: 'assets/images/actor2.jpg', name: 'Samuel l jackson'),
    ActorModel(image: 'assets/images/actor4.jpg', name: 'Emma watson'),
    ActorModel(image: 'assets/images/actor3.jpg', name: 'Margot robbie'),
  ];
}*/
