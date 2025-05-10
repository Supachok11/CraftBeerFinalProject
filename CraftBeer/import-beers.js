//
//  import-beers.js
//  CraftBeer
//
//  Created by Supachok Chatupamai on 10/5/2568 BE.
//


// import-beers.js
const admin = require('firebase-admin');
const beers  = require('./beers.json');

// load your private key
const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function importBeers() {
    for (const beer of beers) {
        const docRef = await db.collection('beers').add(beer);
        console.log(`Imported ${beer.name} → ${docRef.id}`);
    }
    console.log('All done!');
    process.exit(0);
}

importBeers().catch(err => {
    console.error(err);
    process.exit(1);
});
