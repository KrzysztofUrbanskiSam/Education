import React, { useState } from "react";
import PropTypes from "prop-types";
import { runScript } from "./scriptService";

function OutputSection({ creativeIds, daBranchName, bidderBranchName, language, tvModels }) {
  const [output, setOutput] = useState("");

  const handleRunScript = async () => {
    const result = await runScript(creativeIds, daBranchName, bidderBranchName, language, tvModels);
    setOutput(result);
  };

  return (
    <div className="output-section">
      <button onClick={handleRunScript}>Uruchom skrypt</button>
      <pre>{output || "Enter creative id first"}</pre>
    </div>
  );
}

OutputSection.propTypes = {
  creativeIds: PropTypes.string.isRequired,
  daBranchName: PropTypes.string,
  bidderBranchName: PropTypes.string,
  language: PropTypes.string,
  tvModels: PropTypes.array,
};

export default OutputSection;
