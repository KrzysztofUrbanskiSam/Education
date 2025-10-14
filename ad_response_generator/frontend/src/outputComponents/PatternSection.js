import React, { useState } from "react";
import PropTypes from "prop-types";
import { openMock, validateGeneratedResponse } from "./scriptService";

function PatternSection({ creativeType, output }) {
  const [pattern, setPattern] = useState("");
  const [validateResult, setValidateResult] = useState("");

  const handleOpenMock = async () => {
    const result = await openMock(creativeType);
    setPattern(result);
    setValidateResult("");
  };

  const verifyOutput = async () => {
    const result = await validateGeneratedResponse(creativeType);
    setValidateResult(result);
    setPattern("");
  };

  return (
    <div className="pattern-section">
      <button name="openMock" onClick={verifyOutput}>
        Verify ad response
      </button>
      <button name="openMock" onClick={handleOpenMock}>
        Open ad response pattern
      </button>
      <pre>
        {pattern
          ? JSON.stringify(pattern, null, 2)
          : validateResult
          ? JSON.stringify(validateResult, null, 2)
          : "No pattern loaded choose creative type"}
      </pre>
    </div>
  );
}

PatternSection.propTypes = {
  creativeType: PropTypes.string.isRequired,
};

export default PatternSection;
