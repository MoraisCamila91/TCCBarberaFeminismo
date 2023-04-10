import json
import requests
from rauth import OAuth1Service

def auth_def():
    requestURL = "https://api.twitter.com/oauth/request_token"
    accessURL = "https://api.twitter.com/oauth/access_token"
    authURL = "https://api.twitter.com/oauth/authorize"
    consumerKey = ""
    consumerSecret = ""

    twitter = OAuth1Service(
        consumer_key=consumerKey,
        consumer_secret=consumerSecret,
        name='twitter',
        request_token_url=requestURL,
        access_token_url=accessURL,
        authorize_url=authURL,
        #header_auth=True
        )

    request_token, request_token_secret = twitter.get_request_token(params={'oauth_callback': 'http://127.0.0.1:5000/callback'})

    authorize_url = twitter.get_authorize_url(request_token)

    print('Visit this URL in your browser: ' + authorize_url)

    verifier = input('Enter PIN from browser: ')

    session = twitter.get_auth_session(request_token, request_token_secret, data={'oauth_verifier': verifier})

    print('Access token:', session.access_token)
    print('Access token secret:', session.access_token_secret)

def main():   
    url = 'https://api.twitter.com/1.1/direct_messages/events/new.json'
    headers = {
        'Authorization': 'OAuth oauth_consumer_key="", oauth_nonce="AUTO_GENERATED_NONCE", oauth_signature="AUTO_GENERATED_SIGNATURE", oauth_signature_method="HMAC-SHA1", oauth_timestamp="AUTO_GENERATED_TIMESTAMP", oauth_token="", oauth_version="1.0"',
        'Content-Type': 'application/json'
    }
    data = '{"event": {"type": "message_create", "message_create": {"target": {"recipient_id": "1612776902460162049"}, "message_data": {"text": "Hello World!"}}}}'

    response = requests.post(url, headers=headers, data=data)

    print(response)
    print(response.content)
    print(response.text)
     

if __name__ == "__main__":
    auth_def()
    main()