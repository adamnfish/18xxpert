import { test, expect } from '@playwright/test';
import { screenshot } from './utils';

test('verifies a real user journey through the app', async ({ page }, testInfo) => {
  await page.setViewportSize({ width: 412, height: 915 });

  // load homepage
  await page.goto('/');
  await screenshot('welcome', page, testInfo);

  // click start to load companies page
  await page.getByRole('button', { name: 'Start' }).click();
  await expect(page).toHaveTitle(/New company/);
  await screenshot('companies', page, testInfo);

  // select the brown company
  await page.getByRole('button', { name: 'brown' }).click();
  await expect(page).toHaveTitle(/Routes/);
  await screenshot('routes-brown', page, testInfo);

  // click add route for the brown company
  await page.getByRole('button', { name: 'add route' }).click();
  await screenshot('routes-brown', page, testInfo);

  // use the keypad to enter a route amount
  await page.getByRole('button', { name: '4' }).click();
  await page.getByRole('button', { name: '0', exact: true }).click();
  await page.getByRole('button', { name: '7' }).click();
  await page.getByRole('button', { name: 'backspace' }).click();
  await screenshot('routes-brown', page, testInfo);

  // navigate to next route and enter an amount there using the +/- 10 buttons
  await page.getByRole('button', { name: 'add route' }).click();
  await screenshot('routes-brown', page, testInfo);
  await page.getByRole('button', { name: '2' }).click();
  await page.getByRole('button', { name: '0', exact: true }).click();
  await page.getByRole('button', { name: 'add 10' }).click();
  await page.getByRole('button', { name: 'add 10' }).click();
  await page.getByRole('button', { name: 'subtract 10' }).click();
  await screenshot('routes-brown', page, testInfo);

  // close the keypad
  await page.getByRole('button', { name: 'close' }).click();
  await screenshot('routes-brown', page, testInfo);

  // return to the routes screen
  await page.getByRole('button', { name: 'Manage companies' }).click();
  await screenshot('companies', page, testInfo);
  // should show the routes total for the brown company
  const brownButton = await page.getByRole('button', { name: 'brown', exact: true });
  await expect(brownButton).toHaveText('$70')

  // select the cyan company
  await page.getByRole('button', { name: 'cyan' }).click();
  await expect(page).toHaveTitle(/Routes/);
  await screenshot('routes-cyan', page, testInfo);
  // other company selector on routes page should include its total
  const brownCompanySelector = await page.getByRole('button', { name: 'brown company', exact: true });
  await expect(brownCompanySelector).toHaveText('$70')

  // add some routes
  await page.getByRole('button', { name: 'add route' }).click();
  await screenshot('routes-cyan', page, testInfo);
  await page.getByRole('button', { name: '2' }).click();
  await page.getByRole('button', { name: '0', exact: true }).click();
  await screenshot('routes-cyan', page, testInfo);

  // use keyboard controls to select next route
  await page.keyboard.press('ArrowDown');
  await screenshot('routes-cyan', page, testInfo);
  await page.getByRole('button', { name: '6' }).click();
  await page.getByRole('button', { name: '0', exact: true }).click();
  await screenshot('routes-cyan', page, testInfo);

  // delete route
  await page.getByRole('button', { name: 'Delete route 1' }).click();
  await screenshot('routes-cyan', page, testInfo);

  // switch to the brown company
  await brownCompanySelector.click();
  await screenshot('routes-brown', page, testInfo);
  // check cyan company's amount is correct in the company bar
  const cyanCompanySelector = await page.getByRole('button', { name: 'cyan company', exact: true });
  await expect(cyanCompanySelector).toHaveText('$60')
});
