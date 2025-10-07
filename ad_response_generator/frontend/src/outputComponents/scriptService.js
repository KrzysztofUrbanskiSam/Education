const runScript = async (creativeIds, daBranchName, bidderBranchName, language, tvModels) => {
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
  try {
    const res = await fetch("http://localhost:5000/upload", {
      method: "POST",
      headers: {
        "Content-Type": "text/plain",
      },
      body: mockName,
    });
    const text = await res.text();
    return text;
  } catch (err) {
    console.error("Fetch error:", err);
    return `Błąd: ${err.message}`;
  }
};

export { runScript, openMock };
