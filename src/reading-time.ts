import { readingTime } from 'reading-time-estimator';

const WORDS_PER_MINUTE = 275;

export function getReadingTime(content: string): number {
  return Math.max(1, readingTime(content, { wordsPerMinute: WORDS_PER_MINUTE }).minutes);
}