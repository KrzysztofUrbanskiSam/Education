import React, { useState } from "react";
import PropTypes from "prop-types";
import { runScript } from "./scriptService";
import Loader from "../Loader";

function OutputSection({
  creativeIds,
  daBranchName,
  bidderBranchName,
  language,
  tvModels,
}) {
  const [output, setOutput] = useState("");
  const [isAdResponseGenerating, setIsAdResponseGenerating] = useState(false);

  const handleRunScript = async () => {
    let result = "";
    if (creativeIds) {
      setIsAdResponseGenerating(true);
      setOutput("");

      result = await runScript(
        creativeIds,
        daBranchName,
        bidderBranchName,
        language,
        tvModels
      );
    }
    setIsAdResponseGenerating(false);
    setOutput(result);
  };

  return (
    <div className="output-section">
      <button onClick={handleRunScript}>Wygeneruj add response</button>
      {isAdResponseGenerating ? (
        <div>
          <Loader />
          <pre>Generating for: {creativeIds}</pre>
        </div>
      ) : (
        <pre>
          {output || "Enter creative id first"}
        </pre>
      )}
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
