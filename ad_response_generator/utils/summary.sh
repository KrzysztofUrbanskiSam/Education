function print_summary() {
    echo "INFO: Printing summary"
    local index=0
    local summary_file="${OUTPUT}/summary.json"
    local json_output="{}"
    for creative_id in ${CREATIVES_IDS[@]}; do
        echo "INFO: Summary for ${creative_id} - '${CREATIVES_NAMES[$index]}'"
        echo -e "INFO:\tParquet file:               ${CREATIVES_PARQUETS[$index]}"
        $DEBUG && echo -e "INFO:\tBert file:                  ${CREATIVES_BERT[$index]}"
        echo -e "INFO:\tTerm file:                  ${CREATIVES_TERM[$index]}"
        echo -e "INFO:\tAd request:                 ${CREATIVES_AD_REQUESTS[$index]}"
        echo -e "INFO:\tAd request:  (prod example) ${CREATIVES_PROD_AD_REQUESTS[$index]}"
        echo -e "INFO:\tAd response:                ${CREATIVES_AD_RESPONSES_FORMATTED[$index]}"
        echo -e "INFO:\tAd response: (prod example) ${CREATIVES_PROD_AD_RESPONSES_FORMATTED[$index]}"

        json_output=$(echo "$json_output" | jq \
            --arg cid "$creative_id" \
            --arg c_parquet "${CREATIVES_PARQUETS[$index]%$EMPTY_MARK}" \
            --arg ad_req "${CREATIVES_AD_REQUESTS[$index]%$EMPTY_MARK}" \
            --arg ad_resp "${CREATIVES_AD_RESPONSES_FORMATTED[$index]%$EMPTY_MARK}" \
            --arg c_term "${CREATIVES_TERM[$index]%$EMPTY_MARK}" \
            --arg c_bert "${CREATIVES_BERT[$index]%$EMPTY_MARK}" \
            '. + {($cid): {"ad_request_file": $ad_req,
                           "ad_response_file": $ad_resp,
                           "parquet_file": $c_parquet,
                           "term_file": $c_term,
                           "bert_file": $c_bert}}')

        # Save JSON output to file
        echo "$json_output" | jq --indent 2 . > ${summary_file}
        index=$(expr $index + 1)
    done

    echo "INFO: JSON summary saved to ${summary_file}"
    end=`date +%s.%3N`
    runtime=$( echo "$end - $start" | bc -l )

    echo "INFO: Sript executed in ${runtime}s"
}