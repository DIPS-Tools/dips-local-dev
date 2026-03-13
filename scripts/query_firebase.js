#!/usr/bin/env node

/**
 * Query Firebase Emulator
 * Usage: NODE_PATH=./upconsent/node_modules node scripts/query_firebase.js <collection> <documentId> [field]
 *
 * Examples:
 *   NODE_PATH=./upconsent/node_modules node scripts/query_firebase.js requests yulzifpdW0cu8p99pSBb
 *   NODE_PATH=./upconsent/node_modules node scripts/query_firebase.js requests yulzifpdW0cu8p99pSBb extraText
 *   NODE_PATH=./upconsent/node_modules node scripts/query_firebase.js requests yulzifpdW0cu8p99pSBb metadata.audit_request_id
 */

// Set NODE_PATH if not already set
if (!process.env.NODE_PATH) {
  const path = require('path');
  process.env.NODE_PATH = path.join(__dirname, '../upconsent/node_modules');
  require('module').Module._initPaths();
}

// Set emulator environment variable BEFORE requiring firebase-admin
process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST = 'localhost:9099';

const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin pointing to emulator
admin.initializeApp({
  projectId: 'cactus-consent-tool'
});

const db = admin.firestore();

// Parse command line arguments
const args = process.argv.slice(2);

if (args.length < 2) {
  console.error('Usage: node scripts/query_firebase.js <collection> <documentId> [field]');
  console.error('Examples:');
  console.error('  node scripts/query_firebase.js requests yulzifpdW0cu8p99pSBb');
  console.error('  node scripts/query_firebase.js requests yulzifpdW0cu8p99pSBb extraText');
  console.error('  node scripts/query_firebase.js owners someOwnerId');
  process.exit(1);
}

const [collection, documentId, field] = args;

// Query the document
db.collection(collection).doc(documentId).get()
  .then(doc => {
    if (!doc.exists) {
      console.error(`❌ Document not found: ${collection}/${documentId}`);
      process.exit(1);
    }

    const data = doc.data();

    if (field) {
      // Extract specific field (supports nested fields with dot notation)
      const fieldParts = field.split('.');
      let value = data;

      for (const part of fieldParts) {
        if (value && typeof value === 'object' && part in value) {
          value = value[part];
        } else {
          console.error(`❌ Field not found: ${field}`);
          process.exit(1);
        }
      }

      console.log(`✅ ${collection}/${documentId}.${field}:`);
      console.log(JSON.stringify(value, null, 2));
    } else {
      // Print entire document
      console.log(`✅ Document: ${collection}/${documentId}`);
      console.log(JSON.stringify(data, null, 2));
    }

    process.exit(0);
  })
  .catch(error => {
    console.error('❌ Error querying Firebase:', error.message);
    process.exit(1);
  });
