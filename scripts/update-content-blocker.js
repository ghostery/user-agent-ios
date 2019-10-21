'use strict';

const fs = require('fs');
const fetch = require("node-fetch");

(async function () {
  const adList = await (await fetch("https://cdn.cliqz.com/adblocker/configs/safari-ads/allowed-lists.json")).json();

  // Ad Network rules
  const adNetworkRulesUrl = adList.safari.network;
  const adNetworkRules = await (await fetch(adNetworkRulesUrl)).text();
  fs.writeFileSync('content-blocker-lib-ios/Lists/safari-ads-network.json', adNetworkRules);

  // Ads Cosmetic rules
  const adCosmeticRulesUrl = adList.safari.cosmetic;
  const adCosmeticRules = await (await fetch(adCosmeticRulesUrl)).text();
  fs.writeFileSync('content-blocker-lib-ios/Lists/safari-ads-cosmetic.json', adCosmeticRules);

  const trackingList = await (await fetch("https://cdn.cliqz.com/adblocker/configs/safari-tracking/allowed-lists.json")).json();

  // Tracking Network rules
  const trackingNetworkRulesUrl = trackingList.safari.network;
  const trackingNetworkRules = await (await fetch(trackingNetworkRulesUrl)).text();
  fs.writeFileSync('content-blocker-lib-ios/Lists/safari-tracking-network.json', trackingNetworkRules);
})();
