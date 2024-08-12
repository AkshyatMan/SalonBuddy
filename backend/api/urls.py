from django.urls import path, include
from rest_framework_simplejwt.views import TokenRefreshView
from api import views


urlpatterns = [
    path("token/", views.MyTokenObtainedPairView.as_view(), name='token_obtain_pair'),
    path("token/refresh/", TokenRefreshView.as_view(), name='token_refresh'),
    
    path("register/", views.RegisterView.as_view(), name='register'),
    path("login/", views.LoginAPIView.as_view(), name='login'),
    path("dashboard/", views.dashboard, name='dashboard'),

    path('users/', views.UserListView.as_view(), name='user_list'),
    path('users/<int:id>/', views.UserDetailView.as_view(), name='user_detail'),

    path('profile/', views.UserProfileView.as_view(), name='user_profile'),
    path('profile/update/', views.ProfileUpdateAPIView.as_view(), name='profile_update'),
    path('profile/image/', views.ProfileImageView.as_view(), name='profile_image'),

    path('barbershops/', views.list_barbershops, name='barbershop_list'),
    path('barbershops/in-service/', views.InServiceBarbershopListView.as_view(), name='in_service_barbershop_list'),
    path('barbershops/create/<int:user_id>/', views.create_barbershop, name='create_barbershop'),
    path('barbershops/<int:pk>/', views.BarbershopDetailView.as_view(), name='barbershop_detail'),
    path('barbershops/<int:pk>/update/', views.update_barbershop, name='barbershop_update'),
    path('barbershops/<int:pk>/delete/', views.delete_barbershop, name='barbershop_delete'),
    path('barbershops/user/<int:user_id>/', views.get_barbershop_by_user, name='barbershop_list_by_user'),

    path('styles-of-cut/<int:pk>/', views.StyleOfCutDetailView.as_view(), name='style_of_cut_detail'),
    path('barbershops/<int:barbershop_id>/styles-of-cut/', views.StyleOfCutListView.as_view(), name='style_of_cut_list'),
    path('barbershops/<int:barbershop_id>/styles-of-cut/create/', views.StyleOfCutCreateView.as_view(), name='style_of_cut_create'),
    path('barbershops/<int:barbershop_id>/styles-of-cut/create-default/', views.create_default_styles, name='create_default_styles'),

    path('barbershops/<int:barbershop_id>/appointments/', views.AppointmentListView.as_view(), name='appointment_list'),
    path('barbershops/<int:barbershop_id>/appointments/create/', views.AppointmentCreateView.as_view(), name='appointment_create'),
    path('barbershops/<int:barbershop_id>/appointments/<int:pk>/', views.AppointmentDetailView.as_view(), name='appointment_detail'),
    path('verified-appointments/<int:user_id>/', views.VerifiedAppointmentsView.as_view(), name='verified_appointments'),

    path('update-device-token/', views.UpdateDeviceTokenView.as_view(), name='update_device_token'),
    path('appointments/<int:pk>/generate-pdf/', views.AppointmentDetailView.as_view(), name='generate_appointment_pdf'),

    path('barber-appointments/<int:barbershop_id>/verified/', views.BarberAppointmentsView.as_view(), name='barber_appointments_verified'),
    path('barber-appointments/<int:barbershop_id>/not-verified/', views.BarberUnverifiedAppointmentsView.as_view(), name='barber_appointments_not_verified'),

    path('barbershops/<int:barbershop_id>/barbers/', views.BarberListView.as_view(), name='barber_list'),
    path('barbershops/<int:barbershop_id>/barber/create/', views.BarberCreateView.as_view(), name='barber_create'),
    path('barbershops/<int:barbershop_id>/barbers/<int:barber_id>/', views.BarberDetailView.as_view(), name='barber_detail'),

    path('activate/<uidb64>/<token>/', views.activate_account, name='activate'),
    path('forgot_password/', views.forgot_password, name='forgot_password'),
]
