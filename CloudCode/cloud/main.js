var Mailgun = require('mailgun')
Mailgun.initialize('taptone.me', 'key-9jagq65bowrwiamosv35pcxj9lxt4q74')

var randomCode = function() {
  var nums = []
  for (i = 0; i < 5; i++) {
    nums.push(Math.floor((Math.random() * 10)))
  }
  return nums.join("")
}

var emailCode = function(email, code, response) {

  var emailText =  "\
  You requested a sign in code for Taptone.\n\n\
  Enter the following code: "+code+"\n\n\
  If you did not try to sign in, you can ignore this message. Someone may have used your email address by mistake.\n\n\
  www.taptone.me\n\n\
  This email was sent by Taptone, 175 Orchard St #5C, New York, NY 10002"

  Mailgun.sendEmail({
      to: email,
      from: "taptone.me@gmail.com",
      subject: "Your sign in code: "+code,
      text: emailText
    }, {
      success: function(httpResponse) {
            response.success(code) },
      error: function(httpResponse) {
            response.error("Failed to email code") }
  }) 
}

var handleError = function(error, response) {
  if (error.code === Parse.Error.OBJECT_NOT_FOUND) {
    response.error("Object not found")
  } 
  else if (error.code === Parse.Error.CONNECTION_FAILED) {
    response.error("Connection error")
  }
  else {
    response.error(message)
  } 
}

Parse.Cloud.define("login", function(request, response) {
  var email = request.params.email 

  var emailQuery = new Parse.Query(Parse.User)
  emailQuery.equalTo("email", email)

  emailQuery.find({
    success: function(results) {
      if (results.length) {
        var user = results[0]
        var code = randomCode()
        Parse.Cloud.useMasterKey()
        user.setPassword(code)
        user.save().then(function(user) {
          emailCode(email, code, response)
        }, function(error) {
          response.error("Failed to send code")
        })
      }
      else {
        response.error("User not found")
      }
    },
    error: function(error) {
      handleError(error, response)
    }
  })
})

Parse.Cloud.define("signup", function(request, response) {
  var email = request.params.email
  var name = request.params.displayName
  var code = randomCode()

  var emailQuery = new Parse.Query(Parse.User)
  emailQuery.equalTo("email", email)
  emailQuery.find({
    success: function(results) {
      if (results.length) {
        response.error("Email taken")
      }
      else {
        Parse.User.signUp(email, code,
         { email: email,
           code: code,
           name: name}, {
          success: function(user) {
            emailCode(email, code, response)
          },
          error: function(user, error) {
            response.error("Signup failed")
          }
        })
      }
    },
    error: function(error) {
      handleError(error, response)
    }
  })
})

