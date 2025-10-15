import React from "react";
import PropTypes from "prop-types";

const languages = ["en", "ko", "pl"];

const LanguageSelect = ({ language, setLanguage }) => {
  const changeLanguage = (e) => {
    setLanguage(e.target.value);
  };

  return (
    <div className="languages-singleselect-section">
      <h4>TV language</h4>
      <select
        value={language}
        onChange={changeLanguage}
        className="single-select"
      >
        {languages.map((option) => (
          <option key={option} value={option}>
            {option}
          </option>
        ))}
      </select>
    </div>
  );
};

LanguageSelect.propTypes = {
  language: PropTypes.string.isRequired,
  setLanguage: PropTypes.func.isRequired,
};

export default LanguageSelect;
