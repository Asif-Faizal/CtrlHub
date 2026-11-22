package domain

import "time"

// DayBounds returns the UTC instants for the start and end of a local
// calendar day in the given timezone.
func DayBounds(d Date, tz string) (time.Time, time.Time) {
	loc, err := time.LoadLocation(tz)
	if err != nil {
		loc = time.UTC
	}
	start := time.Date(d.Year(), d.Month(), d.Day(), 0, 0, 0, 0, loc)
	return start.UTC(), start.AddDate(0, 0, 1).UTC()
}

func ValidTimezone(tz string) bool {
	if tz == "" {
		return false
	}
	_, err := time.LoadLocation(tz)
	return err == nil
}
