module.exports = {
  type: "object",
  properties: {
    gamerhub_immersive_thumb_banner: {
      type: "array",
      items: {
        type: "object",
        properties: {
          ad: {
            type: "object",
            properties: {
              adinfo: {
                type: "object",
                properties: {
                  adid: { type: "string" },
                  adtype: { type: "string" },
                  guid: { type: "string" },
                  adResponseVersion: { type: "string" },
                  responseTime: { type: "string" },
                  expireTime: { type: "string" },
                  refreshInterval: { type: "string" },
                },
                required: [
                  "adid",
                  "adtype",
                  "guid",
                  "adResponseVersion",
                  "responseTime",
                  "expireTime",
                  "refreshInterval",
                ],
              },
              creative: {
                type: "object",
                properties: {
                  cid: { type: "string" },
                  clicktype: { type: "string" },
                  clickaction: {
                    type: "object",
                    properties: {
                      url: { type: "string" },
                    },
                    required: ["url"],
                  },
                  adtext: { type: "string" },
                  colorPreset: {
                    type: "object",
                    properties: {
                      buttonBackground: { type: "string" },
                      buttonLabel: { type: "string" },
                    },
                    required: ["buttonBackground", "buttonLabel"],
                  },
                  backgroundimage: {
                    type: "object",
                    properties: {
                      width: { type: "string" },
                      height: { type: "string" },
                      imageurl: { type: "string" },
                      position: { type: "string" },
                    },
                    required: ["width", "height", "imageurl", "position"],
                  },
                  thumbnailimage: {
                    type: "object",
                    properties: {
                      width: { type: "string" },
                      height: { type: "string" },
                      imageurl: { type: "string" },
                    },
                    required: ["width", "height", "imageurl"],
                  },
                  autoplay: {
                    type: "object",
                    properties: {
                      video: {
                        type: "object",
                        properties: {
                          vast: { type: "string" },
                          videourl: { type: "string" },
                          duration: { type: "string" },
                        },
                        required: ["vast", "videourl", "duration"],
                      },
                    },
                    required: ["video"],
                  },
                  tracking: {
                    type: "object",
                    properties: {
                      impressionreportingurl: { type: "string" },
                      clickreporturl: { type: "string" },
                      thirdpartyclickreporturl: {
                        type: "array",
                        items: { type: "string" },
                      },
                      thirdpartyimpressionreportingurl: {
                        type: "array",
                        items: { type: "string" },
                      },
                      exitdelayreporturl: { type: "string" },
                      blankreportingurl: { type: "string" },
                      replayreporturl: { type: "string" },
                      hoverreporturl: { type: "string" },
                      thirdpartyhoverreporturl: {
                        type: "array",
                        items: { type: "string" },
                      },
                    },
                    required: [
                      "impressionreportingurl",
                      "clickreporturl",
                      "thirdpartyclickreporturl",
                      "thirdpartyimpressionreportingurl",
                      "exitdelayreporturl",
                      "blankreportingurl",
                      "replayreporturl",
                      "hoverreporturl",
                      "thirdpartyhoverreporturl",
                    ],
                  },
                },
                required: [
                  "cid",
                  "clicktype",
                  "clickaction",
                  "adtext",
                  "colorPreset",
                  "backgroundimage",
                  "thumbnailimage",
                  "autoplay",
                  "tracking",
                ],
              },
            },
            required: ["adinfo", "creative"],
          },
        },
        required: ["ad"],
      },
    },
  },
  required: ["gamerhub_immersive_thumb_banner"],
};
