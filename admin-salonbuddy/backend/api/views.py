from rest_framework.exceptions import ValidationError
from rest_framework.generics import ListAPIView,RetrieveAPIView
from django.shortcuts import render, get_object_or_404
from api.models import Barber, User, Profile , Barbershop,StyleOfCut,Appointment
from .Serializer import BarberSerializer, UserSerializer, MyTokenObtainPairSerializer, RegisterSerializer, ProfileSerializer , LoginSerializer,BarbershopSerializer,StyleOfCutSerializer,AppointmentSerializer
from django.contrib.auth import authenticate
from rest_framework.decorators import api_view, permission_classes
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework import generics, status ,permissions
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
import datetime

class UserDetailView(RetrieveAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    lookup_field = 'id'

class UserListView(ListAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer

class UpdateUserAPIView(generics.RetrieveUpdateDestroyAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    lookup_url_kwarg = 'user_id'

class MyTokenObtainedPairView(TokenObtainPairView):
    serializer_class = MyTokenObtainPairSerializer

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (AllowAny,)
    serializer_class = RegisterSerializer

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
    
#appointment

# Helper Functions
def is_within_operating_hours(date_time):
    # Assuming operating hours are 9 AM to 7 PM
    return 9 <= date_time.hour < 19

def is_not_holiday(date_time):
    # Example: Assuming a simple rule for holidays, adjust according to your needs
    return date_time.weekday() != 6  # 6 represents Sunday

# appointment
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
        barbershop_id = kwargs.get('barbershop_id')
        try:
            barbershop = Barbershop.objects.get(id=barbershop_id)
        except Barbershop.DoesNotExist:
            return Response({'error': 'Barbershop not found.'}, status=status.HTTP_404_NOT_FOUND)

        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        # Perform additional validation here if needed
        
        self.perform_create(serializer, barbershop)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)

    def perform_create(self, serializer, barbershop):
        appointment_time = serializer.validated_data.get('date_time')
        
        # Assuming you have functions like is_within_operating_hours and is_not_holiday defined
        if not is_within_operating_hours(appointment_time) or not is_not_holiday(appointment_time):
            raise ValidationError('Appointment time is outside operating hours or on a holiday.')
        
        serializer.save(barbershop=barbershop)

class VerifiedAppointmentsView(generics.ListAPIView):
    serializer_class = AppointmentSerializer

    def get_queryset(self):
        user_id = self.kwargs['user_id']
        return Appointment.objects.filter(customer_id=user_id, verified=True)
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

class BarberAppointmentsView(ListAPIView):
    serializer_class = AppointmentSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        barbershop_id = self.kwargs['barbershop_id']
        return Appointment.objects.filter(barbershop_id=barbershop_id, verified=True)
    