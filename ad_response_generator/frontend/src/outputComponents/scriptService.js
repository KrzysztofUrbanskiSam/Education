const runScript = async (
  creativeIds,
  daBranchName,
  bidderBranchName,
  language,
  tvModels
) => {
  try {
    const res = await fetch("http://localhost:5000/script", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        "creatives-ids": creativeIds,
        "tv-models": tvModels,
        "branch-data-activation": daBranchName,
        "branch-bidder": bidderBranchName,
        language: language,
      }),
    });
    const text = await res.text();

    return creativeIds ? text : "There is no creative id entered";
  } catch (err) {
    console.error("Fetch error:", err);
    return `Błąd: ${err.message}`;
  }
};

const openMock = async (mockName) => {
  if (mockName === "") mockName = "creative type is not proper";
  try {
    const res = await fetch("http://localhost:5000/upload_mock", {
      method: "POST",
      headers: {
        "Content-Type": "text/plain",
      },
      body: mockName,
    });

    const jsonData = await res.text();
    return jsonData;
  } catch (err) {
    console.error("Fetch error:", err);
    return `Błąd: ${err.message}`;
  }
};

const openAdResponse = async (pathName) => {
  if (pathName === "") pathName = "path name is not proper";
  try {
    const res = await fetch("http://localhost:5000/open_ad_reponse", {
      method: "POST",
      headers: {
        "Content-Type": "text/plain",
      },
      body: pathName,
    });

    const jsonData = await res.json();
    return jsonData;
  } catch (err) {
    console.error("Fetch error:", err);
    return `Błąd: ${err.message}`;
  }
};

const validateGeneratedResponse = async (pathName) => {
  if (pathName === "") pathName = "path name is not proper";
  try {
    const res = await fetch("http://localhost:5000/validate", {
      method: "POST",
      headers: {
        "Content-Type": "text/plain",
      },
      body: pathName,
    });

    const jsonData = await res.json();
    return jsonData;
  } catch (err) {
    console.error("Fetch error:", err);
    return `Błąd: ${err.message}`;
  }
};

export { runScript, openMock, validateGeneratedResponse, openAdResponse };