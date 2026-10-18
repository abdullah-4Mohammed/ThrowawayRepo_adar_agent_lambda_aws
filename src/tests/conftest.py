import os
import sys

# let the tests import the lambda code from src/lambda
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "lambda"))
