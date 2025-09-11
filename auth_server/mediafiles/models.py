from django.db import models


class MediaFile(models.Model):
    FILE_IMAGE = 'image'
    FILE_AUDIO = 'audio'
    FILE_TYPES = [
        (FILE_IMAGE, 'Image'),
        (FILE_AUDIO, 'Audio'),
    ]

    owner_id = models.IntegerField()
    file = models.FileField(upload_to='uploads/%Y/%m/%d/')
    file_type = models.CharField(max_length=10, choices=FILE_TYPES)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.file_type}:{self.file.name}"


