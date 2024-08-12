from django.http import HttpResponse, HttpResponseBadRequest, JsonResponse
from rest_framework.exceptions import ValidationError
from rest_framework.generics import ListAPIView,RetrieveAPIView
from django.shortcuts import render, get_object_or_404
from api.models import Barber, User, Profile , Barbershop,StyleOfCut,Appointment
# from backend.backend import settings
from .Serializer import BarberSerializer, UserSerializer, MyTokenObtainPairSerializer, RegisterSerializer, ProfileSerializer , LoginSerializer,BarbershopSerializer,StyleOfCutSerializer,AppointmentSerializer
from django.contrib.auth import authenticate
from rest_framework.decorators import api_view, permission_classes
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework import generics, status ,permissions
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from pyfcm import FCMNotification
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph, Table, TableStyle
import os
from django.utils.datastructures import MultiValueDict
from .tasks import send_reminder_notifications  # Import the Celery task
from django.utils import timezone
from django.contrib.auth.tokens import PasswordResetTokenGenerator
from django.contrib.sites.shortcuts import get_current_site
from django.template.loader import render_to_string
from django.utils.http import urlsafe_base64_encode
from django.utils.encoding import force_bytes
from django.core.mail import EmailMessage
from .tokens import AccountActivationTokenGenerator, account_activation_token
from django.utils.http import urlsafe_base64_decode
from django.shortcuts import redirect
from django.contrib.auth.tokens import default_token_generator
from django.contrib import messages
from django.urls import reverse
# from django.core.mail import send_mail
from django.contrib.auth import get_user_model
from django.utils.encoding import force_str
from django.core.mail import send_mail

class UserDetailView(RetrieveAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    lookup_field = 'id'

class UserListView(ListAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer

class MyTokenObtainedPairView(TokenObtainPairView):
    serializer_class = MyTokenObtainPairSerializer

@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def dashboard(request):
    if request.method == "GET":
        response = f"Hey {request.user}, you are getting a response"
        return Response({'response': response}, status=status.HTTP_200_OK)
    elif request.method == "POST":
        text = request.POST.get("text")
        response = f"Hey {request.user}, your text is {text}"
        return Response({'response': response}, status=status.HTTP_200_OK)
    return Response({}, status=status.HTTP_400_BAD_REQUEST)

class LoginAPIView(APIView):
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            password = serializer.validated_data['password']

            # Authenticate the user
            user = authenticate(request, email=email, password=password)

            if user:
                # Generate tokens
                refresh = RefreshToken.for_user(user)
                access_token = str(refresh.access_token)

                # Return tokens
                return Response({'access': access_token}, status=status.HTTP_200_OK)
            else:
                return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
class UserProfileView(generics.RetrieveAPIView):
    serializer_class = ProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user.profile
 
class ProfileUpdateAPIView(generics.UpdateAPIView):
    queryset = Profile.objects.all()
    serializer_class = ProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user.profile

    def update(self, request, *args, **kwargs):
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)

        # Get the image data from the request
        image_data = request.FILES.get('image')
        if image_data:
            # Update the profile image
            instance.image.save(instance.user.username + '_profile_image.png', image_data)

        self.perform_update(serializer)
        return Response(serializer.data)
class ProfileImageView(APIView):
    def get(self, request):
        profile = Profile.objects.get(user=request.user)
        if profile.image:
            image_url = profile.image.url
            return JsonResponse({'image_url': image_url})
        else:
            return JsonResponse({'error': 'Image not found'}, status=404)   
        
@api_view(['POST'])
def create_barbershop(request, userId):
    request_data = request.data.copy() 
    request_data['user'] = userId

    serializer = BarbershopSerializer(data=request_data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
def list_barbershops(request):
    queryset = Barbershop.objects.all()
    serializer = BarbershopSerializer(queryset, many=True)
    return Response(serializer.data)

@api_view(['PUT','PATCH'])
def update_barbershop(request, pk):
    barbershop = get_object_or_404(Barbershop, pk=pk)
    serializer = BarbershopSerializer(barbershop, data=request.data,partial=True)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['DELETE'])
def delete_barbershop(request, pk):
    barbershop = get_object_or_404(Barbershop, pk=pk)
    barbershop.delete()
    return Response(status=status.HTTP_204_NO_CONTENT)

@api_view(['GET'])
def get_barbershop_by_user(request, user_id):
    try:
        barbershop = Barbershop.objects.filter(user_id=user_id)
        serializer = BarbershopSerializer(barbershop,many=True)
        return Response(serializer.data)
    except Barbershop.DoesNotExist:
        return Response({'error': 'Barbershop not found'}, status=404)
    
class BarbershopDetailView(RetrieveAPIView):
    serializer_class = BarbershopSerializer

    def get_queryset(self):
        # Get the barbershop ID from the URL
        barbershop_id = self.kwargs['pk']
        # Filter the queryset to retrieve only the specific barbershop
        return Barbershop.objects.filter(pk=barbershop_id)

class InServiceBarbershopListView(generics.ListAPIView):
    queryset = Barbershop.objects.filter(in_service=True)
    serializer_class = BarbershopSerializer

class StyleOfCutDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = StyleOfCut.objects.all()
    serializer_class = StyleOfCutSerializer

class StyleOfCutCreateView(generics.CreateAPIView):
    queryset = StyleOfCut.objects.all()
    serializer_class = StyleOfCutSerializer

class StyleOfCutListView(generics.ListCreateAPIView):
    serializer_class = StyleOfCutSerializer

    def get_queryset(self):
        # Get the barbershop_id from URL query parameters
        barbershop_id = self.kwargs['barbershop_id']
        # Filter StyleOfCut instances based on barbershop_id
        return StyleOfCut.objects.filter(barbershop_id=barbershop_id)
    
@api_view(['POST'])
def create_default_styles(request, barbershop_id):
    try:
        barbershop = Barbershop.objects.get(id=barbershop_id)
        StyleOfCut.create_default_styles(barbershop)
        return Response({'message': 'Default styles created successfully.'}, status=200)
    except Barbershop.DoesNotExist:
        return Response({'message': 'Barbershop not found.'}, status=404)
    except Exception as e:
        return Response({'message': f'Error creating default styles: {str(e)}'}, status=500)
    

# appointment
class BarberAppointmentsView(ListAPIView):
    serializer_class = AppointmentSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        barbershop_id = self.kwargs['barbershop_id']
        return Appointment.objects.filter(barbershop_id=barbershop_id, verified=True)

class BarberUnverifiedAppointmentsView(ListAPIView):
    serializer_class = AppointmentSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        barbershop_id = self.kwargs['barbershop_id']
        return Appointment.objects.filter(barbershop_id=barbershop_id, verified=False)    
    
class AppointmentListView(generics.ListAPIView):
    serializer_class = AppointmentSerializer

    def get_queryset(self):
        # Get the barbershop ID from the URL parameter
        barbershop_id = self.kwargs['barbershop_id']
        
        # Filter appointments by the barbershop ID
        queryset = Appointment.objects.filter(barbershop_id=barbershop_id)
        
        return queryset
    
class AppointmentDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = AppointmentSerializer
    queryset = Appointment.objects.all()
    lookup_field = 'pk'  # Use 'pk' as the lookup field

    def patch(self, request, *args, **kwargs):
        return self.partial_update(request, *args, **kwargs)


class AppointmentCreateView(generics.CreateAPIView):
    queryset = Appointment.objects.all()
    serializer_class = AppointmentSerializer

    def create(self, request, *args, **kwargs):
        # Extract the barbershop ID from the URL kwargs
        barbershop_id = kwargs.get('barbershop_id')
        try:
            # Retrieve the barbershop instance
            barbershop = Barbershop.objects.get(id=barbershop_id)
        except Barbershop.DoesNotExist:
            # Return a 404 response if barbershop is not found
            return Response({'error': 'Barbershop not found.'}, status=status.HTTP_404_NOT_FOUND)

        # Validate the request data using the serializer
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        # Extract the appointment time from the validated data
        appointment_time = serializer.validated_data.get('date_time').time()
        
        # Check if the appointment time is within the opening hours of the barbershop
        if not self.is_within_working_hours(appointment_time, barbershop):
            return Response({'error': 'Appointment time is outside working hours.'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Set the barbershop field in the serializer
        serializer.validated_data['barbershop'] = barbershop
        
        # Perform creation of the appointment
        self.perform_create(serializer)

        # Return a success response with the created data
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)

    def is_within_working_hours(self, appointment_time, barbershop):
        return barbershop.opening_time <= appointment_time < barbershop.closing_time



class VerifiedAppointmentsView(generics.ListAPIView):
    serializer_class = AppointmentSerializer

    def get_queryset(self):
        user_id = self.kwargs['user_id']
        return Appointment.objects.filter(customer_id=user_id, verified=True)
       

class UpdateDeviceTokenView(APIView):
    def post(self, request):
        token = request.data.get('device_token')
        if not token:
            return Response({'error': 'Device token not provided'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Update the user's profile with the device token
        profile = request.user.profile
        profile.device_token = token
        profile.save()

        return Response({'success': 'Device token updated successfully'}, status=status.HTTP_200_OK)





def generate_appointment_pdf(appointment):
    # Create a PDF document
    file_path = f"appointment_{appointment.id}.pdf"
    doc = SimpleDocTemplate(file_path, pagesize=letter)
    styles = getSampleStyleSheet()
    style_normal = styles['Normal']
    style_bold = styles['Heading1']

    # Appointment details
    appointment_details = [
        ("Date:", appointment.date_time.strftime('%Y-%m-%d')),
        ("Time:", appointment.date_time.strftime('%H:%M')),

        # Add more details as needed...
    ]

    # Create a table for appointment details
    appointment_table = Table(appointment_details, colWidths=[100, 200])
    appointment_table.setStyle(TableStyle([('BACKGROUND', (0, 0), (-1, 0), colors.grey),
                                           ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
                                           ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
                                           ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                                           ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
                                           ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
                                           ('GRID', (0, 0), (-1, -1), 1, colors.black)]))

    # Build the PDF document
    doc.build([Paragraph("Appointment Details", style_bold), Paragraph("", style_normal), appointment_table])

    return file_path

class AppointmentDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = AppointmentSerializer
    queryset = Appointment.objects.all()
    lookup_field = 'pk'  # Use 'pk' as the lookup field

    def patch(self, request, *args, **kwargs):
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        
        # Check if the appointment is being marked as verified
        if 'verified' in request.data and request.data['verified'] is True:
            # Generate PDF for completed appointment
            pdf_file = generate_appointment_pdf(instance)
            # Optionally, you can send the PDF to the user or provide a download link
            
        self.perform_update(serializer)
        return Response(serializer.data)
    
#barber
class BarberCreateView(generics.CreateAPIView):
    queryset = Barber.objects.all()
    serializer_class = BarberSerializer

class BarberListView(generics.ListAPIView):
    serializer_class = BarberSerializer

    def get_queryset(self):
        barbershop_id = self.kwargs['barbershop_id']
        return Barber.objects.filter(barbershop_id=barbershop_id)
    
class BarberDetailView(APIView):
    def get(self, request, barbershop_id, barber_id):
        # Retrieve the barber object or return 404 if not found
        barber = get_object_or_404(Barber, id=barber_id, barbershop_id=barbershop_id)

        # Serialize the barber object to JSON
        serializer = BarberSerializer(barber)

        return Response(serializer.data, status=status.HTTP_200_OK)



from django.core.mail import EmailMessage
from django.contrib.sites.shortcuts import get_current_site
from django.http import HttpRequest  # Import HttpRequest

from django.contrib.sites.shortcuts import get_current_site
from django.http import HttpRequest  # Import HttpRequest

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (AllowAny,)
    serializer_class = RegisterSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()

        # Send verification email
        self.send_verification_email(request, user)

        return Response({'message': 'User created successfully. Please check your email for verification.'}, status=status.HTTP_201_CREATED)

    account_activation_token = AccountActivationTokenGenerator()

    def send_verification_email(self, request, user):
        current_site = get_current_site(request)
        subject = 'Activate Your Account'
        message = render_to_string('account_activation_email.html', {
            'user': user,
            'domain': current_site.domain,
            'uid': urlsafe_base64_encode(force_bytes(user.pk)),
            'token': account_activation_token.make_token(user),
        })
        email = EmailMessage(subject, message, to=[user.email])
        email.send()

account_activation_token = AccountActivationTokenGenerator()

def activate_account(request, uidb64, token):
    try:
        uid = urlsafe_base64_decode(uidb64).decode()
        user = User.objects.get(pk=uid)
    except (TypeError, ValueError, OverflowError, User.DoesNotExist):
        return HttpResponseBadRequest('Invalid user or token.')

    if account_activation_token.check_token(user, token):
        # Update the 'verified' field to True
        user.verified = True
        user.save()
        return HttpResponse('Your email has been successfully verified.')
    else:
        return HttpResponseBadRequest('Invalid token.')




User = get_user_model()

# def forgot_password(request):
#     if request.method == 'POST':
#         email = request.POST.get('email')
#         user = User.objects.filter(email=email).first()
#         if user:
#             # Generate password reset token
#             token = default_token_generator.make_token(user)

#             # Send password reset email
#             subject = 'Reset Your Password'
#             message = render_to_string('reset_password_email.html', {
#                 'user': user,
#                 'uid': urlsafe_base64_encode(force_bytes(user.pk)),
#                 'token': token,
#             })
#             send_mail(subject, message, 'from@example.com', [user.email])

#             messages.success(request, 'Password reset email sent. Please check your inbox.')
#             return redirect('login')
#         else:
#             messages.error(request, 'User with this email does not exist.')
#     return render(request, 'forgot_password.html')

# def reset_password(request, uidb64, token):
#     try:
#         uid = force_str(urlsafe_base64_decode(uidb64))
#         user = User.objects.get(pk=uid)
#     except (TypeError, ValueError, OverflowError, User.DoesNotExist):
#         user = None

#     if user and default_token_generator.check_token(user, token):
#         if request.method == 'POST':
#             password = request.POST.get('password')
#             confirm_password = request.POST.get('confirm_password')
#             if password == confirm_password:
#                 user.set_password(password)
#                 user.save()
#                 messages.success(request, 'Password reset successfully.')
#                 return redirect('login')
#             else:
#                 messages.error(request, 'Passwords do not match.')
#         return render(request, 'reset_password.html', {'uidb64': uidb64, 'token': token})
#     else:
#         messages.error(request, 'Invalid password reset link.')
#         return redirect('login')
def forgot_password(request):
    if request.method == 'POST':
        email = request.POST.get('email')
        user = User.objects.filter(email=email).first()
        if user:
            # Generate password reset token
            token = default_token_generator.make_token(user)

            # Send password reset email
            subject = 'Reset Your Password'
            message = render_to_string('reset_password_email.html', {
                'user': user,
                'uid': urlsafe_base64_encode(force_bytes(user.pk)),
                'token': token,
            })
            send_mail(subject, message, 'from@example.com', [user.email])

            # Return a success response
            return HttpResponse(status=200)
        else:
            # Return a response indicating user does not exist
            return HttpResponse("User with this email does not exist.", status=404)
    else:
        # Return a response indicating only POST requests are allowed
        return HttpResponse("Only POST requests are allowed for this endpoint.", status=405)