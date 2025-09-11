from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.decorators import api_view, authentication_classes, permission_classes, parser_classes
from .models import MediaFile
from .serializers import MediaFileSerializer, UploadImageSerializer, UploadAudioSerializer
from .authentication import SimpleJWTNoDBAuthentication
from auth_server.utils import success


@api_view(['POST'])
@authentication_classes([SimpleJWTNoDBAuthentication])
@permission_classes([permissions.IsAuthenticated])
@parser_classes([MultiPartParser, FormParser])
def upload_image(request):
    serializer = UploadImageSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    media = MediaFile.objects.create(
        owner_id=request.user.id or 0,
        file=serializer.validated_data['file'],
        file_type=MediaFile.FILE_IMAGE,
    )
    return success(MediaFileSerializer(media, context={'request': request}).data, message='Image uploaded', status=status.HTTP_201_CREATED)


@api_view(['POST'])
@authentication_classes([SimpleJWTNoDBAuthentication])
@permission_classes([permissions.IsAuthenticated])
@parser_classes([MultiPartParser, FormParser])
def upload_audio(request):
    serializer = UploadAudioSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    media = MediaFile.objects.create(
        owner_id=request.user.id or 0,
        file=serializer.validated_data['file'],
        file_type=MediaFile.FILE_AUDIO,
    )
    return success(MediaFileSerializer(media, context={'request': request}).data, message='Audio uploaded', status=status.HTTP_201_CREATED)


@api_view(['GET'])
@authentication_classes([SimpleJWTNoDBAuthentication])
@permission_classes([permissions.IsAuthenticated])
def list_media(request):
    items = MediaFile.objects.filter(owner_id=request.user.id)
    serializer = MediaFileSerializer(items, many=True, context={'request': request})
    return success(serializer.data, message='Media list')


