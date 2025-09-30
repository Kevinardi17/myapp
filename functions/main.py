
import firebase_admin
from firebase_admin import credentials, firestore
from firebase_functions import https_fn
import sendgrid
from sendgrid.helpers.mail import Mail
import os
import random

# Inisialisasi Firebase Admin SDK
firebase_admin.initialize_app()

@https_fn.on_call()
def send_otp(req: https_fn.Request) -> https_fn.Response:
    """
    Mengirimkan kode OTP ke email pengguna dan menyimpannya di Firestore.
    """
    email = req.data.get("email")
    if not email:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
            message="Email harus diisi."
        )

    # Buat kode OTP acak
    otp = str(random.randint(100000, 999999))

    # Simpan OTP di Firestore
    db = firestore.client()
    db.collection("otps").document(email).set({"otp": otp})

    # Kirim email dengan SendGrid
    message = Mail(
        from_email="kevinardisetyawan57@gmail.com",  # Ganti dengan email pengirim yang terverifikasi di SendGrid
        to_emails=email,
        subject="Kode OTP Anda",
        html_content=f"<strong>Kode OTP Anda adalah:</strong> {otp}"
    )
    try:
        sg = sendgrid.SendGridAPIClient(os.environ.get("SENDGRID_API_KEY"))
        response = sg.send(message)
        return https_fn.Response({"success": True})
    except Exception as e:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INTERNAL,
            message=f"Gagal mengirim email: {e}"
        )
