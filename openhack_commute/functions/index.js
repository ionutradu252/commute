const {onRequest} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const https = require("https");

// defineSecret — creează o variabilă secretă securizată
const openAiKey = defineSecret("OPENAI_API_KEY");

exports.getChatReply = onRequest(
    // --- AICI ESTE MODIFICAREA ---
    // 1. Am adăugat 'cors: true'.
    // Această opțiune îi spune Firebase să gestioneze automat cererile
    // 'OPTIONS' (pre-flight) și să seteze 'Access-Control-Allow-Origin'.
    {
      secrets: [openAiKey],
      cors: true, // Permite cereri de la orice origine
      // Pentru producție, ai putea restricționa:
      // cors: ["https://adresa-ta-web.com"],
    },
    // --- SFÂRȘITUL MODIFICĂRII ---
    (req, res) => {
      // 2. AM ȘTERS BLOCUL TĂU MANUAL DE CORS
      // Liniile 'res.set("...")' și 'if (req.method === "OPTIONS")'
      // nu mai sunt necesare.

      if (req.method !== "POST") {
        res.status(405).send("Method Not Allowed");
        return;
      }

      const userPrompt = req.body.prompt;
      if (!userPrompt) {
        res.status(400).send({error: "Prompt-ul lipsește."});
        return;
      }

      const systemMessage =
      "Ești un asistent util pentru o aplicație de carpooling numită Commute." +
      "Răspunde scurt și la obiect.";

      const postData = JSON.stringify({
        model: "gpt-3.5-turbo",
        messages: [
          {role: "system", content: systemMessage},
          {role: "user", content: userPrompt},
        ],
      });

      const options = {
        hostname: "api.openai.com",
        path: "/v1/chat/completions",
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${openAiKey.value()}`,
        },
      };

      const openaiReq = https.request(options, (openaiRes) => {
        let data = "";
        openaiRes.on("data", (chunk) => {
          data += chunk;
        });
        openaiRes.on("end", () => {
          try {
            const jsonResponse = JSON.parse(data);
            const reply = jsonResponse.choices[0].message.content;
            res.status(200).send({reply: reply.trim()});
          } catch (err) {
            console.error("Eroare la parsare:", err, data);
            res.status(500).send({error: "Eroare la OpenAI."});
          }
        });
      });

      openaiReq.on("error", (err) => {
        console.error("Eroare la request:", err);
        res.status(500).send({error: "Eroare server."});
      });

      openaiReq.write(postData);
      openaiReq.end();
    },
);
