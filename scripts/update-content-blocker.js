const fs = require('fs');
const fetch = require('node-fetch');

(async () => {
  // Ad rules
  const adList = await (await fetch(
    'https://cdn.cliqz.com/adblocker/configs/safari-ads/allowed-lists.json',
  )).json();

  // Ad Network rules
  const adNetworkRulesUrl = adList.safari.network;
  const adNetworkRules = await (await fetch(adNetworkRulesUrl)).text();
  fs.writeFileSync(
    'content-blocker-lib-ios/Lists/safari-ads-network.json',
    adNetworkRules,
  );

  // Ads Cosmetic rules
  const adCosmeticRulesUrl = adList.safari.cosmetic;
  const adCosmeticRules = await (await fetch(adCosmeticRulesUrl)).text();
  fs.writeFileSync(
    'content-blocker-lib-ios/Lists/safari-ads-cosmetic.json',
    adCosmeticRules,
  );

  // Tracking rules
  const trackingList = await (await fetch(
    'https://cdn.cliqz.com/adblocker/configs/safari-tracking/allowed-lists.json',
  )).json();

  // Tracking Network rules
  const trackingNetworkRulesUrl = trackingList.safari.network;
  const trackingNetworkRules = await (await fetch(
    trackingNetworkRulesUrl,
  )).text();
  fs.writeFileSync(
    'content-blocker-lib-ios/Lists/safari-tracking-network.json',
    trackingNetworkRules,
  );

  // Popups rules
  const popupsList = await (await fetch(
    'https://cdn.cliqz.com/adblocker/configs/safari-cookiemonster/allowed-lists.json',
  )).json();

  // Popup Cosmetic rules
  const popupsCosmeticRulesUrl = popupsList.safari.cosmetic;
  const popupsCosmeticRules = await (await fetch(
    popupsCosmeticRulesUrl,
  )).text();
  fs.writeFileSync(
    'content-blocker-lib-ios/Lists/safari-popups-cosmetic.json',
    popupsCosmeticRules,
  );

  // Popup Networkd rules
  const popupsNetworkRulesUrl = popupsList.safari.network;
  const popupsNetworkRules = await (await fetch(popupsNetworkRulesUrl)).text();
  fs.writeFileSync(
    'content-blocker-lib-ios/Lists/safari-popups-network.json',
    popupsNetworkRules,
  );
})();
