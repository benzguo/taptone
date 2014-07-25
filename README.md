G3 makes an iPhone 5S vibrate gently

# Signup flow
1. Enter display name + email
    * code sent if email is unique and valid
2. Enter code
    * log in if code is valid
3. Enter phone number
    * Friends can add you using your phone number

```
curl -X POST \
   -H "X-Parse-Application-Id: RUXkfe7Otj8ROooI0DQxH1AZULZonaz1EA3XFjnk" \
   -H "X-Parse-REST-API-Key: KReh0Wd8yN1Al7o0PR3JVzwHiRwsiyxABhy7NeLN" \
   -H "Content-Type: application/json" \
   -d '{"userId": "DLPQVIs1Yo" }' \
   https://api.parse.com/1/functions/push_notes       
```