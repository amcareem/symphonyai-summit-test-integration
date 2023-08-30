import requests
import smtplib
from email.message import EmailMessage
import time
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)

# Helpdesk API details
API_ENDPOINT = "https://symphonyai.helpdesk/api/tickets"
API_TOKEN = "my_api_token"

# Email details
EMAIL_HOST = "your.smtp.server"
EMAIL_PORT = 587
EMAIL_USER = "ahamed@example.com"
EMAIL_PASS = "ahamedemail_password"

def get_tickets_close_to_violation():
    headers = {
        "Authorization": f"Bearer {API_TOKEN}"
    }

    try:
        response = requests.get(API_ENDPOINT, headers=headers)
        response.raise_for_status()  # Raising HTTPError if the HTTP request returned an unsuccessful status code
        tickets = response.json()

        close_to_violation_tickets = []

        for ticket in tickets:
            time_since_opened = calculate_time_since(ticket["opened_at"])
            sla_time = ticket["sla_time"]
            
            if time_since_opened / sla_time > 0.9:  # Adjust this threshold as needed
                close_to_violation_tickets.append(ticket)
                
        return close_to_violation_tickets
    except requests.RequestException as e:
        logging.error(f"Error fetching tickets: {e}")
        return []

def send_email(ticket):
    msg = EmailMessage()
    msg.set_content(f"Ticket {ticket['id']} is close to violating its SLA!")
    msg["Subject"] = "SLA Violation Alert"
    msg["From"] = EMAIL_USER
    msg["To"] = "support_manager@example.com"

    try:
        with smtplib.SMTP(EMAIL_HOST, EMAIL_PORT) as server:
            server.login(EMAIL_USER, EMAIL_PASS)
            server.send_message(msg)
        logging.info(f"Sent email alert for ticket {ticket['id']}")
    except Exception as e:
        logging.error(f"Error sending email for ticket {ticket['id']}: {e}")

def main():
    while True:  # To keep the script running indefinitely
        tickets = get_tickets_close_to_violation()
        for ticket in tickets:
            send_email(ticket)
        time.sleep(3600)  # Sleep for 1 hour before checking again. Adjust this interval as needed.

if __name__ == "__main__":
    main()
