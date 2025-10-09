import React, { useState } from "react";
import PropTypes from "prop-types";
import { openMock } from "./scriptService";

function TestSection({ creativeType }) {
  const [pattern, setPattern] = useState("");

  const handleOpenMock = async () => {
    const result = await openMock(creativeType);
    setPattern(result);
  };

  return (
    <div className="pattern-section">
      <button name="openMock" onClick={handleOpenMock}>
        Otwórz wzór
      </button>
      <pre>
        {pattern
          ? JSON.stringify(pattern, null, 2)
          : "No pattern loaded choose creative type"}
      </pre>
    </div>
  );
}

TestSection.propTypes = {
  creativeType: PropTypes.string.isRequired,
};

export default TestSection;
