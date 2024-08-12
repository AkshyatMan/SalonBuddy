# tasks.py

import logging
from celery import shared_task
from django.utils import timezone
from api.models import Appointment
from api.notifications import send_notification

logger = logging.getLogger(__name__)

@shared_task
def send_reminder_notifications(appointment_time):
    try:
        # Get all appointments 15 minutes before the specified time
        appointments = Appointment.objects.filter(
            date_time__lte=appointment_time,
            date_time__gte=appointment_time - timezone.timedelta(minutes=15),
            verified=True,  # Assuming only verified appointments should receive notifications
        )

        # Send notifications to each user
        for appointment in appointments:
            user_id = appointment.customer.id
            message = f"Hi {appointment.customer.username}, your appointment is coming up in 15 minutes."
            send_notification.delay(user_id, message)

        logger.info(f"Successfully sent {len(appointments)} reminder notifications.")
    
    except Exception as e:
        logger.error(f"An error occurred while sending reminder notifications: {str(e)}")
