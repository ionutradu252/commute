const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const https = require("https");

// 1️⃣ Definește secretul
const geminiKey = defineSecret("GEMINI_API_KEY");

exports.getChatReply = onRequest(
  { secrets: [geminiKey], cors: true },
  (req, res) => {
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    const userPrompt = req.body.prompt;
    if (!userPrompt) {
      res.status(400).send({ error: "Prompt-ul lipsește." });
      return;
    }

    // 2️⃣ Construiește prompt-ul
    const fullPrompt = `Ești un asistent util pentru o aplicație de carpooling numită Commute.
Răspunde scurt și la obiect. Întrebarea utilizatorului este: ${userPrompt}`;

    // 3️⃣ Creează corpul cererii (JSON)
    const postData = JSON.stringify({
      contents: [{ parts: [{ text: fullPrompt }] }],
    });

    // 4️⃣ Setează endpoint-ul și cheia corectă
    const options = {
      hostname: "generativelanguage.googleapis.com",
      path: `/v1beta/models/gemini-2.5-flash:generateContent?key=${geminiKey.value()}`,
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
    };

    // 5️⃣ Fă cererea HTTPS
    const geminiReq = https.request(options, (geminiRes) => {
      let data = "";
      geminiRes.on("data", (chunk) => {
        data += chunk;
      });

      geminiRes.on("end", () => {
        console.log("Răspuns brut de la Gemini:", data);
        try {
          const jsonResponse = JSON.parse(data);
          const reply =
            jsonResponse?.candidates?.[0]?.content?.parts?.[0]?.text;

          if (!reply) {
            throw new Error("Răspuns gol sau format necunoscut de la Gemini.");
          }

          res.status(200).send({ reply: reply.trim() });
        } catch (err) {
          console.error("Eroare la parsarea JSON de la Gemini:", err, data);
          res
            .status(500)
            .send({ error: "Eroare la interpretarea răspunsului Gemini." });
        }
      });
    });

    geminiReq.on("error", (err) => {
      console.error("Eroare la requestul HTTPS:", err);
      res.status(500).send({ error: "Eroare server (request Gemini)." });
    });

    geminiReq.write(postData);
    geminiReq.end();
  }
);
