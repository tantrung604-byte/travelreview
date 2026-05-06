class TravelTourSeed {
  const TravelTourSeed({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.rating,
    required this.duration,
    required this.imageAsset,
    required this.description,
    required this.itinerary,
    required this.guide,
    required this.places,
    required this.tag,
  });

  final String id;
  final String title;
  final String location;
  final String price;
  final String rating;
  final String duration;
  final String imageAsset;
  final String description;
  final String itinerary;
  final String guide;
  final String places;
  final String tag;
}

class WorldDestinationSeed {
  const WorldDestinationSeed({
    required this.id,
    required this.country,
    required this.tagline,
    required this.emoji,
    required this.imageAsset,
    required this.highlights,
  });

  final String id;
  final String country;
  final String tagline;
  final String emoji;
  final String imageAsset;
  final List<String> highlights;
}

const seededTours = <TravelTourSeed>[
  TravelTourSeed(
    id: 'da-nang-ba-na-hills',
    title: 'Da Nang - Ba Na Hills 3N2D',
    location: 'Da Nang',
    price: '1,290,000 VND',
    rating: '4.9',
    duration: '3 days 2 nights',
    imageAsset: 'assets/images/tour_da_nang.svg',
    description:
        'Explore Da Nang with a balanced itinerary between city highlights and mountain scenery. The package includes hotel pickup, transportation, guide, and basic meals.',
    itinerary:
        'Day 1: Airport transfer, Marble Mountains, Dragon Bridge night view. Day 2: Full day Ba Na Hills and Golden Bridge. Day 3: Son Tra Peninsula and local specialty shopping before checkout.',
    guide:
        'Bring a light jacket for Ba Na Hills weather, and book your cable car slot early in peak season.',
    places:
        'Golden Bridge, Ba Na Hills cable car, Marble Mountains, Son Tra Peninsula, Han River.',
    tag: 'Best seller',
  ),
  TravelTourSeed(
    id: 'sapa-fansipan',
    title: 'Sapa Fansipan Experience 2N1D',
    location: 'Lao Cai',
    price: '1,890,000 VND',
    rating: '4.8',
    duration: '2 days 1 night',
    imageAsset: 'assets/images/tour_sapa.svg',
    description:
        'A short but complete Sapa trip with cable car access, village walk, and local market stop. Suitable for families and first-time visitors.',
    itinerary:
        'Day 1: Hanoi departure, Cat Cat village walk, local dinner. Day 2: Fansipan cable car, mountain viewpoint, return transfer.',
    guide:
        'Use good walking shoes, carry cash for village shops, and check weather because mountain fog can affect visibility.',
    places:
        'Fansipan cable car, Cat Cat village, Sapa stone church, mountain viewpoint.',
    tag: 'Hot deal',
  ),
  TravelTourSeed(
    id: 'phu-quoc-hon-thom',
    title: 'Phu Quoc Hon Thom Island 4N3D',
    location: 'Phu Quoc',
    price: '2,490,000 VND',
    rating: '4.9',
    duration: '4 days 3 nights',
    imageAsset: 'assets/images/tour_phu_quoc.svg',
    description:
        'Island-focused itinerary with cable car, beach activities, and seafood experience. Great for couples and family groups.',
    itinerary:
        'Day 1: Airport transfer and beach leisure. Day 2: Hon Thom cable car and island activities. Day 3: South island tour and seafood market. Day 4: Free morning and airport transfer.',
    guide:
        'Carry sun protection and waterproof bags for island movement. Sunset slots for cable car views are usually the best.',
    places:
        'Hon Thom cable car, Sunset Town, Sao Beach, Ham Ninh seafood market.',
    tag: 'Family pick',
  ),
];

const seededWorldDestinations = <WorldDestinationSeed>[
  WorldDestinationSeed(
    id: 'hong-kong',
    country: 'Hong Kong',
    tagline: 'Disneyland, Victoria Peak, urban nightlife',
    emoji: '🇭🇰',
    imageAsset: 'assets/images/world_hong_kong.svg',
    highlights: [
      'Hong Kong Disneyland one-day pass and family combo',
      'Peak Tram and skyline night viewpoints',
      'Lan Kwai Fong nightlife and bar districts',
      'Tsim Sha Tsui promenade and harbor walk',
    ],
  ),
  WorldDestinationSeed(
    id: 'trung-quoc',
    country: 'China',
    tagline: 'Beijing, Shanghai and iconic landmarks',
    emoji: '🇨🇳',
    imageAsset: 'assets/images/world_china.svg',
    highlights: [
      'Shanghai Disneyland entrance and fast pass options',
      'Great Wall day trip from Beijing',
      'Zhangjiajie glass bridge and national park routes',
      'The Bund evening cruise and city skyline view',
    ],
  ),
  WorldDestinationSeed(
    id: 'nhat-ban',
    country: 'Japan',
    tagline: 'Tokyo, Osaka, Kyoto and themed experiences',
    emoji: '🇯🇵',
    imageAsset: 'assets/images/world_japan.svg',
    highlights: [
      'Universal Studios Japan pass with optional express lane',
      'Tokyo Disneyland and DisneySea park tickets',
      'teamLab Planets digital art museum admission',
      'Kyoto kimono rental with photo package',
    ],
  ),
  WorldDestinationSeed(
    id: 'han-quoc',
    country: 'Korea',
    tagline: 'Seoul, Busan, Jeju and culture hotspots',
    emoji: '🇰🇷',
    imageAsset: 'assets/images/world_korea.svg',
    highlights: [
      'Lotte World Seoul day pass and attractions',
      'N Seoul Tower observatory and city view package',
      'Everland theme park and safari options',
      'Jeju island nature and cafe tour combinations',
    ],
  ),
  WorldDestinationSeed(
    id: 'singapore',
    country: 'Singapore',
    tagline: 'Sentosa, Marina Bay, Gardens by the Bay',
    emoji: '🇸🇬',
    imageAsset: 'assets/images/world_singapore.svg',
    highlights: [
      'Universal Studios Singapore all-day entrance',
      'Gardens by the Bay Flower Dome and Cloud Forest',
      'Marina Bay Sands SkyPark observation ticket',
      'S.E.A. Aquarium family package',
    ],
  ),
  WorldDestinationSeed(
    id: 'thail-lan',
    country: 'Thailand',
    tagline: 'Bangkok, Pattaya, Phuket and night markets',
    emoji: '🇹🇭',
    imageAsset: 'assets/images/world_thailand.svg',
    highlights: [
      'Safari World Bangkok ticket and performance combo',
      'Chao Phraya dinner cruise',
      'Pattaya Coral Island day activities',
      'Phuket Fantasea and Carnival Magic night shows',
    ],
  ),
];

final seededTourById = <String, TravelTourSeed>{
  for (final t in seededTours) t.id: t,
};

