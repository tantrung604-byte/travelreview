import process from 'node:process';
import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';

const args = new Set(process.argv.slice(2));
const isDryRun = args.has('--dry-run') || !args.has('--apply');

const projectId = process.env.FIREBASE_PROJECT_ID;
if (!projectId) {
  console.error('Missing FIREBASE_PROJECT_ID environment variable.');
  process.exit(1);
}

const seededTours = [
  {
    id: 'da-nang-ba-na-hills',
    title: 'Da Nang - Ba Na Hills 3N2D',
    description:
      'Explore Da Nang with a balanced itinerary between city highlights and mountain scenery. The package includes hotel pickup, transportation, guide, and basic meals.',
    itinerary:
      'Day 1: Airport transfer, Marble Mountains, Dragon Bridge night view. Day 2: Full day Ba Na Hills and Golden Bridge. Day 3: Son Tra Peninsula and local specialty shopping before checkout.',
    guide:
      'Bring a light jacket for Ba Na Hills weather, and book your cable car slot early in peak season.',
    places:
      'Golden Bridge, Ba Na Hills cable car, Marble Mountains, Son Tra Peninsula, Han River.',
    price: '1,290,000 VND',
    rating: '4.9'
  },
  {
    id: 'sapa-fansipan',
    title: 'Sapa Fansipan Experience 2N1D',
    description:
      'A short but complete Sapa trip with cable car access, village walk, and local market stop. Suitable for families and first-time visitors.',
    itinerary:
      'Day 1: Hanoi departure, Cat Cat village walk, local dinner. Day 2: Fansipan cable car, mountain viewpoint, return transfer.',
    guide:
      'Use good walking shoes, carry cash for village shops, and check weather because mountain fog can affect visibility.',
    places:
      'Fansipan cable car, Cat Cat village, Sapa stone church, mountain viewpoint.',
    price: '1,890,000 VND',
    rating: '4.8'
  },
  {
    id: 'phu-quoc-hon-thom',
    title: 'Phu Quoc Hon Thom Island 4N3D',
    description:
      'Island-focused itinerary with cable car, beach activities, and seafood experience. Great for couples and family groups.',
    itinerary:
      'Day 1: Airport transfer and beach leisure. Day 2: Hon Thom cable car and island activities. Day 3: South island tour and seafood market. Day 4: Free morning and airport transfer.',
    guide:
      'Carry sun protection and waterproof bags for island movement. Sunset slots for cable car views are usually the best.',
    places:
      'Hon Thom cable car, Sunset Town, Sao Beach, Ham Ninh seafood market.',
    price: '2,490,000 VND',
    rating: '4.9'
  }
];

initializeApp({
  credential: applicationDefault(),
  projectId
});

const db = getFirestore();

console.log(`Mode: ${isDryRun ? 'dry-run' : 'apply'}`);
console.log(`Project: ${projectId}`);

if (isDryRun) {
  for (const t of seededTours) {
    console.log(`[DRY] tours/${t.id} -> title="${t.title}", price="${t.price}"`);
  }
  process.exit(0);
}

const batch = db.batch();
for (const t of seededTours) {
  const ref = db.collection('tours').doc(t.id);
  batch.set(
    ref,
    {
      title: t.title,
      description: t.description,
      itinerary: t.itinerary,
      guide: t.guide,
      places: t.places,
      price: t.price,
      rating: t.rating,
      emoji: '📍',
      seeded: true,
      updatedAt: FieldValue.serverTimestamp()
    },
    { merge: true }
  );
}

await batch.commit();
console.log(`Seed completed. Upserted ${seededTours.length} tour documents.`);

