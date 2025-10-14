const express = require("express");
const cors = require("cors");
const { exec } = require("child_process");

const fs = require("fs");
const path = require("path");

const { validateGamingHubImmersionContentPlus } = require("./validators");

// Create Express app
const app = express();

// Middleware
app.use(cors());
app.use(express.text());
app.use(express.json());

// Routes
app.get("/", (req, res) => {
  res.json({ message: "Welcome to the Express server!" });
});

app.post("/script", (req, res) => {
  const body = req.body;
  let params = "";
  for (const key in body) {
    params += `--${key} `;
    if (Array.isArray(body[key])) {
      body[key].forEach((el) => {
        params += `${el} `;
      });
    }
    if (typeof body[key] === "string" || body[key] instanceof String) {
      body[key].split(",").forEach((el) => {
        params += `${el} `;
      });
    }
  }

  exec(
    `bash ../ad_response_generator.sh ${params}`,
    (error, stdout, stderr) => {
      if (error) {
        console.error(`Błąd: ${error.message}`);
        return res.status(500).send(error.message);
      }
      if (stderr) {
        console.error(`stderr: ${stderr}`);
        return res.status(500).send(stderr);
      }

      res.send(stdout);
    }
  );
});

const readMockFile = (creativeType) => {
  return new Promise((resolve, reject) => {
    const filePath = path.resolve(
      __dirname,
      "mocks",
      `${creativeType}_response.json`
    );
    fs.readFile(filePath, "utf8", (error, data) => {
      if (error) {
        reject(
          new Error(
            `Failed to read mock file ${creativeType}: ${error.message}`
          )
        );
      } else {
        resolve(data);
      }
    });
  });
};

const readAdResponseFile = (pathName) => {
  return new Promise((resolve, reject) => {
    const filePath = path.resolve(__dirname, "../", `${pathName}`);

    fs.readFile(filePath, "utf8", (error, data) => {
      if (error) {
        reject(
          new Error(
            `Failed to read ad response file ${pathName}: ${error.message}`
          )
        );
      } else {
        resolve(data);
      }
    });
  });
};

const validateResponseData = (data) => {
  const jsonData = JSON.parse(data);
  const valid = validateGamingHubImmersionContentPlus(jsonData);
  if (!valid) {
    const errors = validateGamingHubImmersionContentPlus.errors;
    throw new Error(`Validation failed: ${JSON.stringify(errors)}`);
  }
  return jsonData;
};

const confirmGeneratedData = (data) => {
  const jsonData = JSON.parse(data);
  const valid = validateGamingHubImmersionContentPlus(jsonData);
  if (!valid) {
    const errors = validateGamingHubImmersionContentPlus.errors;
    throw new Error(`Validation failed: ${JSON.stringify(errors)}`);
  }
  return valid;
};

app.post("/upload", async (req, res) => {
  try {
    const creativeType = req.body;

    const fileData = await readMockFile(creativeType);

    const validatedData = validateResponseData(fileData);

    return res.status(200).json(validatedData);
  } catch (error) {
    console.error("Upload endpoint error:", error.message);

    return res.status(500).json({
      error: "Upload failed",
      message: error.message,
    });
  }
});

app.post("/validate", async (req, res) => {
  try {
    const creativeType = req.body;

    const fileData = await readMockFile(creativeType);

    const validatedData = confirmGeneratedData(fileData);

    return res.status(200).json(validatedData);
  } catch (error) {
    console.error("Upload endpoint error:", error.message);

    return res.status(500).json({
      error: "Upload failed",
      message: error.message,
    });
  }
});

app.get("/api/status", (req, res) => {
  res.json({
    status: "Server is running",
    timestamp: new Date().toISOString(),
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: "Route not found" });
});

// Server configuration
const PORT = process.env.PORT || 5000;

// Start server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
  console.log(`Visit http://localhost:${PORT} to access the server`);
});