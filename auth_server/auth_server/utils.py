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
    def extract_message(payload):
        if not isinstance(payload, dict):
            return 'Validation error'
        if isinstance(payload.get('detail'), str):
            return payload['detail']
        if isinstance(payload.get('message'), str):
            return payload['message']
        # Flatten first error from field lists
        for v in payload.values():
            if isinstance(v, (list, tuple)) and v:
                first = v[0]
                if isinstance(first, str):
                    return first
        return 'Validation error'
    message = extract_message(data)

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


