import React from "react";
import PropTypes from "prop-types";

const CreativeIdsInput = ({ creativeIds, setCreativeIds }) => {
  return (
    <div className="creativeids-input-section">
      <h4>Enter creative ids divided by comma</h4>
      <input
        onChange={(e) => {
          setCreativeIds(e.target.value.replace(/[^0-9,]/g, ""));
        }}
        type="text"
        inputMode="text"
        placeholder="eg: 111111,222222,333333"
        value={creativeIds}
      />
    </div>
  );
};

CreativeIdsInput.propTypes = {
  creativeIds: PropTypes.string.isRequired,
  setCreativeIds: PropTypes.func.isRequired,
};

export default CreativeIdsInput;
