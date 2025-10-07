import React from "react";
import PropTypes from "prop-types";

const creativeTypes = [
  {
    value: "gaming_hub_immersion_content_plus",
    label: "GH Immersion Content Plus",
  },
  { value: "gaming_hub_immersion_content", label: "GH Immersion Content" },
  { value: "gaming_hub_restangle_static", label: "GH Rectangle static" },
  {
    value: "gaming_hub_auto_play_video",
    label: "GH Rectangle Auto Play Video",
  },
];

const CreativeTypeSelect = ({ creativeType, setCreativeType }) => {
  const handleSingleselectChange = (e) => {
    setCreativeType(e.target.value);
  };

  return (
    <div className="creativetypes-singleselect-section">
      <h4>Creative type</h4>
      <select
        value={creativeType}
        onChange={handleSingleselectChange}
        className="single-select"
      >
        <option key="choose" value="">
          choose
        </option>
        {creativeTypes.map((option) => (
          <option key={option.value} value={option.value}>
            {option.label}
          </option>
        ))}
      </select>
    </div>
  );
};

CreativeTypeSelect.propTypes = {
  creativeType: PropTypes.string.isRequired,
  setCreativeType: PropTypes.func.isRequired,
};

export default CreativeTypeSelect;
