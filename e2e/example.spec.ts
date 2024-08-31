import { test, expect } from '@playwright/test';

test('has correct page title', async ({ page }) => {
  await page.goto('/');

  await expect(page).toHaveTitle(/18xx/);
});

test('can click the start button', async ({ page }) => {
  await page.goto('/');

  await page.getByRole('button', { name: 'Start' }).click();

  await expect(page).toHaveTitle(/New company/);
});
