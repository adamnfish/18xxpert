import { Page } from '@playwright/test';

const screenshotBuilder = () => {
  let prev: { string: number }  = {}

  return async (name: string, page: Page, testInfo) => {
    const current = prev[name] || 0;
    const next = current + 1;
    const screenshot = await page.screenshot({
      scale: 'css'
    });
    await testInfo.attach(`${name}-${next}`, { body: screenshot, contentType: 'image/png' });
    prev[name] = next;
  }
};

export const screenshot = screenshotBuilder();
