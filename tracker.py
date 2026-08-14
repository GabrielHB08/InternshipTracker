import os
import smtplib
from dotenv import load_dotenv
from email.message import EmailMessage
import json
from datetime import date, datetime

load_dotenv()

EMAIL_ADDRESS = os.getenv('EMAIL_ADDRESS')
EMAIL_PASSWORD = os.getenv('EMAIL_PASSWORD')
EMAIL_TO = os.getenv('EMAIL_TO')


def validate_env():
    missing_values = []

    if not EMAIL_ADDRESS:
        missing_values.append("EMAIL_ADDRESS")
    if not EMAIL_PASSWORD:
        missing_values.append("EMAIL_PASSWORD")
    if not EMAIL_TO:
        missing_values.append("EMAIL_TO")

    if missing_values:
        missing = ", ".join(missing_values)
        raise ValueError(f"Missing required .env value(s): {missing}")


def send_email(subject, body):
    validate_env()

    msg = EmailMessage()
    msg['Subject'] = subject
    msg['From'] = EMAIL_ADDRESS
    msg['To'] = EMAIL_TO
    msg.set_content(body)

    with smtplib.SMTP_SSL('smtp.gmail.com', 465) as smtp:
        smtp.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
        smtp.send_message(msg)

def load_applications():
    with open("applications.json", "r") as file:
        return json.load(file)

def check_deadlines():
    applications = load_applications()
    today = date.today()
    open_applications = []

    for application in applications:
        if application.get("status") == "submitted":
            continue

        deadline_value = application.get("deadline")
        deadline = None
        days_left = None

        if deadline_value:
            deadline = datetime.strptime(
                deadline_value,
                "%Y-%m-%d"
            ).date()

            days_left = (deadline - today).days

            if days_left < 0:
                continue

        deadline_text = "Unknown"
        days_left_text = "Unknown"

        if deadline:
            deadline_text = deadline.strftime('%B %d, %Y')
            days_left_text = str(days_left)

        open_applications.append(
            {
                "company": application["company"],
                "role": application["role"],
                "link": application["link"],
                "deadline": deadline_text,
                "days_left": days_left_text,
            }
        )

    if not open_applications:
        return

    subject = "Internship application deadline summary"
    body_lines = ["Open internship applications:", ""]

    for application in open_applications:
        body_lines.extend(
            [
                f"{application['company']}",
                f"{application['role']}",
                f"Application link: {application['link']}",
                f"Deadline: {application['deadline']}",
                f"Days remaining: {application['days_left']}",
                "",
            ]
        )

    send_email(subject, "\n".join(body_lines).strip())


if __name__ == "__main__":
    check_deadlines()
