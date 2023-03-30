"""Exception raised for errors during request handling."""


class ServiceError(Exception):

    """
    Attributes:
        message -- explanation of the error
    """

    def __init__(self, message="Service error"):
        self.message = message
        super().__init__(self.message)
