from rest_framework.views import exception_handler
from rest_framework.response import Response


def api_exception_handler(exc, context):
    response = exception_handler(exc, context)
    if response is None:
        return Response({
            'success': False,
            'data': None,
            'message': 'Server error',
        }, status=500)

    data = response.data
    message = None
    if isinstance(data, dict):
        message = data.get('detail') or data.get('message') or 'Validation error'
    else:
        message = 'Validation error'

    return Response({
        'success': False,
        'data': None,
        'message': message,
    }, status=response.status_code)


def success(data=None, message="Success", status=200):
    return Response({
        'success': True,
        'data': data,
        'message': message
    }, status=status)


def error(message="Error", errors=None, status=400):
    return Response({
        'success': False,
        'data': None,
        'message': message,
    }, status=status)


