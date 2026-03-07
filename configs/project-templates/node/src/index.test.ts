import { describe, it, expect } from 'vitest';
import { main } from './index';

describe('main', () => {
  it('should not throw', () => {
    expect(() => main()).not.toThrow();
  });
});