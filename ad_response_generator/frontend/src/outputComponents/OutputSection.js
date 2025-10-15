import { useState } from "react";
import PropTypes from "prop-types";

import {
  runScript,
  openAdResponse,
  validateGeneratedResponse,
} from "./scriptService";
import Loader from "../Loader";

function OutputSection({
  creativeIds,
  daBranchName,
  bidderBranchName,
  language,
  tvModels,
}) {
  const [output, setOutput] = useState("");
  const [outputVisible, setOutputVisible] = useState(true);
  const [isAdResponseGenerating, setIsAdResponseGenerating] = useState(false);
  const [fileRenderedPath, setFileRenderedPath] = useState([]);
  const [adResponse, setAdResponse] = useState({});
  const [validateResult, setValidateResult] = useState({});
  const [contentVisible, setContentVisible] = useState({});

  const toggleOutoutSectionVisible = () => {
    setOutputVisible((previous) => !previous);
  };

  const toggleAdResponseVisible = (path) => {
    setContentVisible((previous) => ({
      ...previous,
      [path]: !previous[path],
    }));
  };

  const parseResult = (result) => {
    const regex = /Ad response:\s*(.*?\.json)/g;
    const matches = [...result.matchAll(regex)];
    const filePaths = matches.map((match) => match[1]);
    setFileRenderedPath(filePaths);
  };

  const verifyAdResponse = async (path) => {
    const result = await validateGeneratedResponse(path);

    setValidateResult((previous) => ({
      ...previous,
      [path]: result,
    }));
    setAdResponse((previous) => ({
      ...previous,
      [path]: "",
    }));
  };

  const handleShowAdResponse = async (path) => {
    setAdResponse((previous) => ({
      ...previous,
      [path]: "",
    }));
    const adResponseContent = await openAdResponse(path);
    setAdResponse((previous) => ({
      ...previous,
      [path]: adResponseContent,
    }));
    setContentVisible((previous) => ({
      ...previous,
      [path]: true,
    }));
    setValidateResult((previous) => ({
      ...previous,
      [path]: "",
    }));
  };

  const verifyAdResponses = async () => {
    fileRenderedPath.forEach(async (path) => {
      const result = await validateGeneratedResponse(path);

      setValidateResult((previous) => ({
        ...previous,
        [path]: result,
      }));
      setAdResponse((previous) => ({
        ...previous,
        [path]: "",
      }));
    });
  };

  const handleShowAdResponses = async () => {
    setAdResponse({});
    fileRenderedPath.forEach(async (path) => {
      const adResponseContent = await openAdResponse(path);
      setContentVisible((previous) => ({
        ...previous,
        [path]: true,
      }));
      setAdResponse((previous) => ({
        ...previous,
        [path]: adResponseContent,
      }));
      setValidateResult({});
    });
  };

  const handleCopy = (path) => {
    navigator.clipboard.writeText(JSON.stringify(adResponse[path], null, 2));
  };

  const handleRunScript = async () => {
    let result = "";
    setOutput("");
    setFileRenderedPath([]);
    setValidateResult({});
    if (creativeIds) {
      setIsAdResponseGenerating(true);

      result = await runScript(
        creativeIds,
        daBranchName,
        bidderBranchName,
        language,
        tvModels
      );
      parseResult(result);
      setOutput(result);
    }
    setIsAdResponseGenerating(false);
  };

  return (
    <>
      <div className="output-section">
        <div className="output-action-section">
          <button onClick={handleRunScript}>Generate ad response</button>
          <button onClick={toggleOutoutSectionVisible}>
            {outputVisible ? "Show" : "Hide"}
          </button>
        </div>
        {isAdResponseGenerating ? (
          <div className="output-action-section">
            <Loader />
            <pre>Generating ad response(s) for: {creativeIds} id(s)</pre>
          </div>
        ) : outputVisible ? (
          <pre>{output || "Enter creative id first"}</pre>
        ) : (
          <></>
        )}
      </div>
      {fileRenderedPath && fileRenderedPath.length ? (
        <>
          <div className="global-action-section">
            <button onClick={handleShowAdResponses}>
              Show all ad responses
            </button>
            {Object.keys(adResponse).length ? (
              <button onClick={verifyAdResponses}>
                Verify all ad responses
              </button>
            ) : (
              <></>
            )}
          </div>
          {Object.keys(adResponse).length ? (
            <div className="responses-section">
              {Object.keys(adResponse).length &&
                fileRenderedPath.map((path) => (
                  <div key={path} className="response-section">
                    {(adResponse[path] || validateResult[path]) && (
                      <button
                        className={`validate-button ${
                          !validateResult[path]
                            ? ""
                            : validateResult[path] === true
                            ? "valid"
                            : "invalid"
                        }`}
                        onClick={() => handleShowAdResponse(path)}
                      >
                        Show ad response for:{" "}
                        {path.match(/\/([^/]+)\.json$/)[1]} id
                      </button>
                    )}
                    {(adResponse[path] || validateResult[path]) && (
                      <button
                        className={`validate-button ${
                          !validateResult[path]
                            ? ""
                            : validateResult[path] === true
                            ? "valid"
                            : "invalid"
                        }`}
                        onClick={() => verifyAdResponse(path)}
                      >
                        Verify ad response
                      </button>
                    )}
                    {adResponse[path] && (
                      <button onClick={() => handleCopy(path)}>
                        Copy to clipboard
                      </button>
                    )}
                    {(adResponse[path] || validateResult[path]) && (
                      <button onClick={() => toggleAdResponseVisible(path)}>
                        {contentVisible[path] ? "Hide" : "Show"}
                      </button>
                    )}
                    {contentVisible[path] && (
                      <pre>
                        {validateResult[path] === true ? (
                          "Add response is all right"
                        ) : validateResult[path] ? (
                          JSON.stringify(validateResult[path], null, 2)
                        ) : adResponse[path] ? (
                          <div>
                            <span
                              style={{ fontWeight: "bold", fontSize: "28px" }}
                            >
                              {path.match(/(runs.*?\.json)/)[1]}
                            </span>
                            <br />
                            {JSON.stringify(adResponse[path], null, 2)}
                          </div>
                        ) : (
                          "Click"
                        )}
                      </pre>
                    )}
                  </div>
                ))}
            </div>
          ) : (
            <></>
          )}
        </>
      ) : (
        <></>
      )}
    </>
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
