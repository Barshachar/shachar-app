import { describe, expect, test } from 'vitest';
import HomePage from '../app/page';

describe('smoke: home page', () => {
  test('home page module exports a function', () => {
    expect(typeof HomePage).toBe('function');
  });
});
