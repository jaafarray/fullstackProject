from rest_framework.response import Response


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
        'errors': errors
    }, status=status)


