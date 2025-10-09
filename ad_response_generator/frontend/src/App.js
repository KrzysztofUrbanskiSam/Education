import React, { useEffect, useState } from "react";

// import TvModelsMultiselect from "./InputComponents/TvModelsMultiselect";
import OutputSection from "./outputComponents/OutputSection";
import TestSection from "./outputComponents/TestSection";
import BranchNameInput from "./InputComponents/BranchNameInput";
import CreativeIdsInput from "./InputComponents/CreativeIdsInput";
import LanguageSelect from "./InputComponents/LanguageSelect";
import CreativeTypeSelect from "./InputComponents/CreativeTypeSelect";

// import logo from "./logo.svg";
import "./App.css";

function App() {
  const [creativeIds, setCreativeIds] = useState("");
  const [daBranchName, setDaBranchName] = useState("master");
  const [bidderBranchName, setBidderBranchName] = useState("main");
  const [creativeType, setCreativeType] = useState("");
  const [language, setLanguage] = useState("en");
  const [testModeVisible, setTestModeVisible] = useState(false);
  // const [tvModels, setTvModels] = useState([]);

  useEffect(() => {}, [testModeVisible]);

  const toggleTestMode = () => {
    setTestModeVisible(!testModeVisible);
  };

  return (
    <div className="App">
      <div className="content">
        <div className="header">
          <h1>Add response generator</h1>
          <button onClick={toggleTestMode}>
            {testModeVisible ? "Hide Test Mode" : "Show Test Mode"}
          </button>
        </div>
        <div className="action">
          <div
            className="generator-section"
            style={{
              flex: testModeVisible
                ? "0 0 calc(50% - 15px)"
                : "0 0 calc(100% - 15px)",
            }}
          >
            <div className="action-section">
              <CreativeIdsInput
                creativeIds={creativeIds}
                setCreativeIds={setCreativeIds}
              />
              <LanguageSelect language={language} setLanguage={setLanguage} />
              <BranchNameInput
                label="Enter data-activation branch name"
                value={daBranchName}
                onChange={setDaBranchName}
              />
              <BranchNameInput
                label="Enter rtb-bidder branch name"
                value={bidderBranchName}
                onChange={setBidderBranchName}
              />
            </div>
            <div className="present-section">
              <OutputSection
                creativeIds={creativeIds}
                daBranchName={daBranchName}
                bidderBranchName={bidderBranchName}
                language={language}
                // tvModels={tvModels}
              />
            </div>

            {/* <TvModelsMultiselect tvModels={tvModels} setTvModels={setTvModels}></TvModelsMultiselect> */}
          </div>
          <div
            className="test-section"
            style={{ display: testModeVisible ? "flex" : "none" }}
          >
            <div className="action-section">
              <CreativeTypeSelect
                creativeType={creativeType}
                setCreativeType={setCreativeType}
              />
            </div>

            <div className="present-section">
              <TestSection creativeType={creativeType} />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
