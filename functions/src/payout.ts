/**
 * Deterministic, cent-exact pot payout helpers.
 */

export interface SeatPayout {
  seat: number;
  amount: number;
}

/**
 * Splits [pot] by ascending seat id, assigning odd cents to the earliest seats.
 */
export function splitPotBySeat(
  pot: number,
  winnerSeats: readonly number[],
): SeatPayout[] {
  if (!Number.isFinite(pot) || pot < 0 || winnerSeats.length === 0) return [];

  const sortedSeats = [...winnerSeats].sort((a, b) => a - b);
  const cents = Math.round(pot * 100);
  const baseCents = Math.floor(cents / sortedSeats.length);
  const remainder = cents % sortedSeats.length;

  return sortedSeats.map((seat, index) => ({
    seat,
    amount: (baseCents + (index < remainder ? 1 : 0)) / 100,
  }));
}

/** Returns one seat's deterministic share of [pot]. */
export function potShareForSeat(
  pot: number,
  winnerSeats: readonly number[],
  seat: number,
): number {
  return splitPotBySeat(pot, winnerSeats).find(
    (payout) => payout.seat === seat,
  )?.amount ?? 0;
}
