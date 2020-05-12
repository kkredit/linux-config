require 'json'

def lambda_handler(event:, context:)
    # TODO implement function
    { statusCode: 200, body: JSON.generate('Hello from Lambda!') }
end
