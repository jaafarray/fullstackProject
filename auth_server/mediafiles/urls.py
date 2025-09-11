from django.urls import path
from .views import upload_image, upload_audio, list_media

urlpatterns = [
    path('media/upload/image/', upload_image),
    path('media/upload/audio/', upload_audio),
    path('media/', list_media),
]


