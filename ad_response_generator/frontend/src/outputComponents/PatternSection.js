import React, { useState } from "react";
import PropTypes from "prop-types";
import { openMock } from "./scriptService";

function PatternSection({ creativeType }) {
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
      <pre>{pattern || "No pattern loaded choose creative type"}</pre>
    </div>
  );
}

PatternSection.propTypes = {
  creativeType: PropTypes.string.isRequired,
};

export default PatternSection;
