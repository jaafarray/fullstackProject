from django.urls import path
from .views import register, login, refresh_token

urlpatterns = [
    path('auth/register/', register, name='register'),
    path('auth/token/', login, name='token_obtain_pair'),
    path('auth/token/refresh/', refresh_token, name='token_refresh'),
]


