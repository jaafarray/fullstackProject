from rest_framework import serializers
from .models import MediaFile


class MediaFileSerializer(serializers.ModelSerializer):
    class Meta:
        model = MediaFile
        fields = ['id', 'owner_id', 'file', 'file_type', 'created_at']
        read_only_fields = ['id', 'created_at']


class UploadImageSerializer(serializers.Serializer):
    file = serializers.ImageField(required=True)


class UploadAudioSerializer(serializers.Serializer):
    file = serializers.FileField(required=True)

    def validate_file(self, value):
        content_type = (getattr(value, 'content_type', '') or '').lower()
        filename = getattr(value, 'name', '')
        # Common MIME types and extensions across browsers/devices
        allowed_mimes = {
            'audio/mpeg',
            'audio/mp3',
            'audio/wav',
            'audio/x-wav',
            'audio/aac',
            'audio/m4a',
            'audio/mp4',
            'audio/ogg',
            'application/octet-stream',  # some Android pickers
        }
        allowed_exts = {'.mp3', '.wav', '.aac', '.m4a', '.ogg'}

        if content_type in allowed_mimes:
            return value

        ext_ok = any(filename.lower().endswith(ext) for ext in allowed_exts)
        if ext_ok:
            return value

        raise serializers.ValidationError('Unsupported audio type')


