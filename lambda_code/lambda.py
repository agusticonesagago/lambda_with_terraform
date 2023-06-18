from typing import Any, Dict


def handler(event: Dict[str, Any], context: Any) -> Dict[str, str]:
    """Lambda function handler.

    Args:
        event: Event data passed to the function.
        context: Lambda function context.

    Returns:
        Response object with a message.
    """
    message = 'Hello {}!'.format(event['key1'])
    return {
        'message': message
    }
