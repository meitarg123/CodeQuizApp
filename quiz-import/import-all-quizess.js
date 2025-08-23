// import-all-quizzes.js
// Run with: node import-all-quizzes.js

import admin from "firebase-admin";
import fs from "fs";
import path from "path";

// Initialize Firebase with your service account
admin.initializeApp({
  credential: admin.credential.cert("./serviceAccount.json"),
});
const db = admin.firestore();

// Folder containing all quiz JSON files
const QUIZ_DIR = "./quizzes";

async function importAll() {
  // Read all files in QUIZ_DIR that end with _quiz.json
  const files = fs.readdirSync(QUIZ_DIR).filter(f => f.endsWith("_quiz.json"));

  if (files.length === 0) {
    console.log("⚠️ No quiz files found in quizzes/ folder.");
    return;
  }

  for (const file of files) {
    const filepath = path.join(QUIZ_DIR, file);
    const quiz = JSON.parse(fs.readFileSync(filepath, "utf8"));

    // Use quiz title (lowercase, underscores) as the Firestore doc ID
    const quizId = quiz.title.toLowerCase().replace(/\s+/g, "_");
    const quizRef = db.collection("quizzes").doc(quizId);

    // Save quiz metadata
    await quizRef.set({
      title: quiz.title,
      subtitle: quiz.subtitle,
      difficulty: quiz.difficulty,
      isPublished: quiz.isPublished,
    });

    // Save questions as subcollection
    const batch = db.batch();
    quiz.questions.forEach((q, idx) => {
      const qRef = quizRef.collection("questions").doc(`${quizId}_q${idx + 1}`);
      batch.set(qRef, q);
    });
    await batch.commit();

    console.log(`✓ Imported quiz: ${quiz.title} from ${file}`);
  }

  console.log("✅ All quizzes imported successfully!");
}

importAll().catch(err => {
  console.error("❌ Error importing quizzes:", err);
  process.exit(1);
});
