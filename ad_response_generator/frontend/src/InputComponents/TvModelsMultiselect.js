import React from "react";
import PropTypes from "prop-types";

function TvModelsMultiselect({ tvModels, setTvModels }) {
  const tvModelOptions = [
    { value: "model1", label: "model 1" },
    { value: "model2", label: "model 2" },
    { value: "model3", label: "model 3" },
    { value: "model4", label: "model 4" },
    { value: "model5", label: "model 5" },
  ];

  const handleTvModelsChange = (e) => {
    const selected = Array.from(
      e.target.selectedOptions,
      (option) => option.value
    );
    setTvModels(selected);
  };

  return (
    <div className="tvmodels-multiselect-section">
      <h4>Choose tv models using ctrl button</h4>
      <select
        multiple
        value={tvModels}
        onChange={handleTvModelsChange}
        className="multi-select"
      >
        {tvModelOptions.map((option) => (
          <option key={option.value} value={option.value}>
            {option.label}
          </option>
        ))}
      </select>
    </div>
  );
}

TvModelsMultiselect.propTypes = {
  tvModels: PropTypes.array.isRequired,
  setTvModels: PropTypes.func.isRequired,
};

export default TvModelsMultiselect;
