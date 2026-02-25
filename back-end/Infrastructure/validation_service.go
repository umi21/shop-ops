package infrastructure

import (
	"errors"
	"regexp"
)

type ValidationService struct {
	emailRegex *regexp.Regexp
	phoneRegex *regexp.Regexp
}

func NewValidationService() *ValidationService {
	// Simple regex patterns - can be improved
	return &ValidationService{
		emailRegex: regexp.MustCompile(`^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,4}$`),
		// Accepting international format optionally with + and digits, length 7-15
		phoneRegex: regexp.MustCompile(`^\+?[0-9]{7,15}$`),
	}
}

func (s *ValidationService) ValidateEmail(email string) error {
	if !s.emailRegex.MatchString(email) {
		return errors.New("invalid email format")
	}
	return nil
}

func (s *ValidationService) ValidatePhone(phone string) error {
	if !s.phoneRegex.MatchString(phone) {
		return errors.New("invalid phone format")
	}
	return nil
}

func (s *ValidationService) ValidateCurrency(currency string) error {
	if len(currency) != 3 {
		return errors.New("currency must be a 3-letter code")
	}
	return nil
}
