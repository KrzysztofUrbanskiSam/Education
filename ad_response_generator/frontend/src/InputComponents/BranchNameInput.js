import React from "react";
import PropTypes from "prop-types";

function BranchNameInput({ label, value, onChange }) {
  const placeholder = "feature/new-branch-name";
  const pattern = "[a-z0-9][a-z0-9._-/]*[a-z0-9]";
  
  return (
    <div className="branchname-input-section">
      <h4>{label}</h4>
      <input
        onChange={(e) => {
          onChange(e.target.value);
        }}
        type="text"
        inputMode="text"
        placeholder={placeholder}
        pattern={pattern}
        value={value}
      />
    </div>
  );
}

BranchNameInput.propTypes = {
  label: PropTypes.string.isRequired,
  value: PropTypes.string.isRequired,
  onChange: PropTypes.func.isRequired,
};

export default BranchNameInput;
