from datetime import datetime, timedelta, timezone
import hashlib
import secrets


class OTPService:
    OTP_LENGTH = 6
    OTP_EXPIRY_MINUTES = 10

    @staticmethod
    def generate() -> str:
        """Generate a cryptographically secure numeric OTP."""
        return f"{secrets.randbelow(1_000_000):06d}"

    @staticmethod
    def hash_otp(otp: str) -> str:
        """Hash OTP before storing it."""
        return hashlib.sha256(otp.encode("utf-8")).hexdigest()

    @classmethod
    def get_expiry(cls) -> datetime:
        return datetime.now(timezone.utc) + timedelta(minutes=cls.OTP_EXPIRY_MINUTES)

    @staticmethod
    def verify(otp: str, otp_hash: str) -> bool:
        expected_hash = OTPService.hash_otp(otp)
        return secrets.compare_digest(expected_hash, otp_hash)
