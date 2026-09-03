import logging
import os

from dotenv import load_dotenv
from mailjet_rest import Client
from mailjet_rest.errors import ApiError, CriticalApiError

logger = logging.getLogger(__name__)

load_dotenv()


class EmailService:
    """
    Mailjet transactional email service.

    Environment variables:
        MAILJET_API_KEY
        MAILJET_SECRET_KEY
        MAILJET_FROM_EMAIL
        MAILJET_FROM_NAME
    """

    def __init__(self):
        self.api_key = os.getenv("MAILJET_API_KEY")
        self.secret_key = os.getenv("MAILJET_SECRET_KEY")
        self.from_email = os.getenv("MAILJET_FROM_EMAIL")
        self.from_name = os.getenv("MAILJET_FROM_NAME", "Email Authenicator")

        if not self.api_key:
            raise RuntimeError("MAILJET_API_KEY is not configured.")

        if not self.secret_key:
            raise RuntimeError("MAILJET_SECRET_KEY is not configured.")

        if not self.from_email:
            raise RuntimeError("MAILJET_FROM_EMAIL is not configured.")

        self.client = Client(
            auth=(self.api_key, self.secret_key),
            version="v3.1",
        )

    def send_email(
        self,
        recipient_email: str,
        subject: str,
        html_content: str,
        text_content: str | None = None,
        recipient_name: str | None = None,
    ) -> bool:
        """
        Send a transactional email through Mailjet.

        Returns:
            True if Mailjet accepted the email.

        Raises:
            ValueError:
                Invalid input.
            RuntimeError:
                Mailjet or network failure.
        """

        if not recipient_email:
            raise ValueError("Recipient email is required.")

        if not subject:
            raise ValueError("Email subject is required.")

        if not html_content:
            raise ValueError("HTML email content is required.")

        message = {
            "From": {
                "Email": self.from_email,
                "Name": self.from_name,
            },
            "To": [
                {
                    "Email": recipient_email,
                    "Name": recipient_name or recipient_email,
                }
            ],
            "Subject": subject,
            "HTMLPart": html_content,
        }

        if text_content:
            message["TextPart"] = text_content

        try:
            response = self.client.send.create(data={"Messages": [message]})

            # Mailjet SDK exposes the HTTP status through status_code.
            if response.status_code not in range(200, 300):
                logger.error(
                    "Mailjet rejected email. Status=%s Response=%s",
                    response.status_code,
                    getattr(response, "json", None),
                )

                raise RuntimeError(
                    f"Mailjet rejected the email (HTTP {response.status_code})."
                )

            logger.info("Email sent successfully to %s", recipient_email)

            return True

        except (ApiError, CriticalApiError) as exc:
            logger.exception(
                "Mailjet API error while sending email to %s",
                recipient_email,
            )
            raise RuntimeError(f"Mailjet API error: {exc}") from exc

        except Exception as exc:
            logger.exception(
                "Unexpected email error while sending to %s",
                recipient_email,
            )
            raise RuntimeError(f"Unable to send email: {exc}") from exc
