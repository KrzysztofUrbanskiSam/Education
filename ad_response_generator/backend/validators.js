const Ajv = require("ajv").default;
const gamingHubImmersionContentPlusSchema = require("./schemas/gaming_hub_immersion_content_plus_schema");
const ajv = new Ajv({ allErrors: true });
const validateGamingHubImmersionContentPlus = ajv.compile(
  gamingHubImmersionContentPlusSchema
);

module.exports = { validateGamingHubImmersionContentPlus };
