export const typography = {
  display: {
    fontSize: 42,
    lineHeight: 48,
    fontWeight: '800' as const,
    letterSpacing: -1.2,
  },
  h1: {
    fontSize: 32,
    lineHeight: 38,
    fontWeight: '800' as const,
  },
  h2: {
    fontSize: 24,
    lineHeight: 30,
    fontWeight: '700' as const,
  },
  body: {
    fontSize: 16,
    lineHeight: 24,
    fontWeight: '400' as const,
  },
  bodyStrong: {
    fontSize: 16,
    lineHeight: 24,
    fontWeight: '600' as const,
  },
  small: {
    fontSize: 13,
    lineHeight: 18,
    fontWeight: '500' as const,
  },
  label: {
    fontSize: 12,
    lineHeight: 16,
    fontWeight: '700' as const,
    letterSpacing: 1.5,
  },
} as const;
