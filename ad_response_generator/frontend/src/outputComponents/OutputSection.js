import React, { useState } from "react";
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
  const [isAdResponseGenerating, setIsAdResponseGenerating] = useState(false);
  const [fileRenderedPath, setFileRenderedPath] = useState([]);
  const [adRespnse, setAdResponse] = useState("");
  const [validateResult, setValidateResult] = useState("");
  console.log("11111111111111111111111111111111111111111111111");
  console.log(fileRenderedPath);

  let pathNames = [];
  const parseResult = (result) => {
    const start = result.indexOf("json");
    if (start === -1) {
      return;
    }
    const end = start - 10;
    pathNames.push(result.substring(start + 4, end));

    parseResult(result.substring(start + end));
    setFileRenderedPath.push(result.substring(start + 4, end));
  };
  // const parseResult = (result) => {
  //   const start = result.indexOf("json") + 4;
  //   const end = start - 45;
  //   const pathName = result.substring(start, end);
  //   setFileRenderedPath(pathName);
  // };

  const verifyAdResponse = async () => {
    const result = await validateGeneratedResponse(fileRenderedPath[0]);
    setValidateResult(result);
    setAdResponse("");
  };

  const handleShowAdResponse = async () => {
    const adRespnseContent = await openAdResponse(fileRenderedPath[0]);
    setAdResponse(adRespnseContent);
    setValidateResult("");
  };

  const handleCopy = () => {
    navigator.clipboard.writeText(JSON.stringify(adRespnse, null, 2));
  };

  const handleRunScript = async () => {
    let result = "";
    setOutput("");
    setFileRenderedPath("");
    setValidateResult("");
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
    <div className="output-section">
      <button onClick={handleRunScript}>Wygeneruj add response</button>
      {isAdResponseGenerating ? (
        <div>
          <Loader />
          <pre>Generating for: {creativeIds}</pre>
        </div>
      ) : (
        <pre>{output || "Enter creative id first"}</pre>
      )}
      {fileRenderedPath.length && (
        <div>
          <button onClick={handleShowAdResponse}>
            Pokaż add response: {fileRenderedPath}
          </button>

          {(adRespnse || validateResult) && (
            <button
              className={`validate-button ${
                validateResult === ""
                  ? ""
                  : validateResult === true
                  ? "valid"
                  : "invalid"
              }`}
              onClick={verifyAdResponse}
            >
              Zweryfikuj ad response
            </button>
          )}
          {(adRespnse || (adRespnse && validateResult)) && (
            <button onClick={handleCopy}>Copy add response to clipboard</button>
          )}
          <pre>
            {validateResult === true
              ? "Add response is all right"
              : validateResult !== ""
              ? JSON.stringify(validateResult, null, 2)
              : adRespnse
              ? JSON.stringify(adRespnse, null, 2)
              : "Click"}
          </pre>
        </div>
      )}
    </div>
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
