const passOnboarding = async () => {
  const scrollview$ = element(by.id('IntroViewController.scrollView'));
  try {
    await expect(scrollview$).toExist();
  } catch (e) {
    // onboarding only shows on first startup
    return;
  }
  await scrollview$.swipe('left');
  const button$ = element(by.id('IntroViewController.startBrowsingButton'));
  await waitFor(button$).toBeVisible().withTimeout(2000);
  await button$.tap();
  const doneButton$ = element(by.label('PrivacyStatementDone'));
  await waitFor(doneButton$).toBeVisible().withTimeout(2000);
  await doneButton$.tap();
  await waitFor(element(by.id('urlbar'))).toBeVisible().withTimeout(2000);
}

describe('Search', function () {
  before(async function () {
    await passOnboarding();
  });

  it('start search', async function () {
    const fakeUrlBar$ = element(by.id('urlbar'));
    await expect(fakeUrlBar$).toBeVisible();
    await fakeUrlBar$.tap();
    const urlbar$ = element(by.id('address'));
    await expect(urlbar$).toBeVisible();
    await urlbar$.typeText('www.amazon.de');
    await waitFor(element(by.text('www.amazon.de')).atIndex(1)).toBeVisible().withTimeout(5000);
  });
});
