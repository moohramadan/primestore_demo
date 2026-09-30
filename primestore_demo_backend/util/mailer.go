package util

import (
	"crypto/rand"
	"fmt"
	"math/big"

	"gopkg.in/gomail.v2"
)

type Mailer struct {
	dialer *gomail.Dialer
	from   string
}

func NewMailer(host string, port int, username, password, from string) *Mailer {
	dialer := gomail.NewDialer(host, port, username, password)
	return &Mailer{dialer: dialer, from: from}
}

func (m *Mailer) SendOTP(to string, otp string) error {
	msg := gomail.NewMessage()
	msg.SetHeader("From", m.from)
	msg.SetHeader("To", to)
	msg.SetHeader("Subject", "Your verification code")
	msg.SetBody("text/plain", fmt.Sprintf("Your verification code is: %s\nThis code expires in 10 minutes.", otp))

	return m.dialer.DialAndSend(msg)
}
func GenerateOTP() (string, error) {
	max := big.NewInt(1000000) // 0 to 999999
	n, err := rand.Int(rand.Reader, max)
	if err != nil {
		return "", err
	}
	return fmt.Sprintf("%06d", n.Int64()), nil
}
