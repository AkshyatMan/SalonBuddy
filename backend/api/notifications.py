from celery import shared_task
from django.conf import settings
from django.core.exceptions import ObjectDoesNotExist
import requests

from api.models import Profile, User

@shared_task
def send_notification(user_id, message):
    try:
        # Fetch user device token and other details from the database
        user = User.objects.get(id=user_id)
        profile = Profile.objects.get(user=user)
        device_token = profile.device_token
        
        # Define the payload for the push notification
        payload = {
            "to": device_token,
            "notification": {
                "title": "Appointment Reminder",
                "body": message,
                "sound": "default"
            },
        }

        # Headers for the Firebase API
        headers = {
            'Content-Type': 'application/json',
            'Authorization': 'key=' + settings.FCM_SERVER_KEY  # Accessing the FCM server key from Django settings
        }

        # Sending the request to FCM
        response = requests.post('https://fcm.googleapis.com/fcm/send', json=payload, headers=headers)
        
        # Check response status
        if response.status_code == 200:
            return {"success": True, "message": "Notification sent successfully"}
        else:
            return {"success": False, "message": "Failed to send notification. Status code: {}".format(response.status_code)}
    
    except ObjectDoesNotExist:
        return {"success": False, "message": "User profile or device token not found"}
    
    except Exception as e:
        return {"success": False, "message": "An error occurred: {}".format(str(e))}
