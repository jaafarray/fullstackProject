from typing import Tuple, Optional
from django.conf import settings
from rest_framework.authentication import BaseAuthentication, get_authorization_header
from rest_framework import exceptions
import jwt


class SimpleTokenUser:
    def __init__(self, user_id: int, username: str):
        self.id = user_id
        self.username = username
        self.is_authenticated = True


class SimpleJWTNoDBAuthentication(BaseAuthentication):
    keyword = b'Bearer'

    def authenticate(self, request) -> Optional[Tuple[SimpleTokenUser, None]]:
        auth = get_authorization_header(request).split()
        if not auth or auth[0].lower() != self.keyword.lower():
            return None
        if len(auth) == 1:
            raise exceptions.AuthenticationFailed('Invalid Authorization header.')
        token = auth[1]
        try:
            payload = jwt.decode(token, settings.SECRET_KEY, algorithms=['HS256'])
        except jwt.ExpiredSignatureError:
            raise exceptions.AuthenticationFailed('Token expired')
        except jwt.InvalidTokenError:
            raise exceptions.AuthenticationFailed('Invalid token')

        user_id = payload.get('user_id') or payload.get('id')
        username = payload.get('username', '')
        if user_id is None:
            raise exceptions.AuthenticationFailed('Invalid payload')
        return SimpleTokenUser(user_id=user_id, username=username), None


