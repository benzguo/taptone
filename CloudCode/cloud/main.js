var Mailgun = require('mailgun');
Mailgun.initialize('taptone.me', 'key-9jagq65bowrwiamosv35pcxj9lxt4q74');

function randomCode() {
  var nums = [];
  for (i = 0; i < 5; i++) {
    nums.push(Math.floor((Math.random() * 10)));
  }
  return nums.join("");
}

function emailCode(email, code, response) {
   Mailgun.sendEmail({
      to: email,
      from: "taptone@taptone.me",
      subject: "Your sign in code: "+code,
      text: "You requested a sign in code for Taptone." }, {
      success: function(httpResponse) {
            response.success(); },
      error: function(httpResponse) {
            response.error("Failed to email code"); }
  }); 
}

function handleError(error, response) {
  if (error.code === Parse.Error.OBJECT_NOT_FOUND) {
    response.error("Object not found")
  } 
  else if (error.code === Parse.Error.CONNECTION_FAILED) {
    response.error("Connection error")
  }
  else {
    response.error("Object not found")
  } 
}

Parse.Cloud.define("login", function(request, response) {
  var email = request.params.email; 

  var emailQuery = new Parse.Query(Parse.User);
  emailQuery.equalTo("email", email);

  emailQuery.find({
    success: function(results) {
      if (results.length) {
        var user = results[0];
        var code = randomCode();
        Parse.Cloud.useMasterKey();
        user.setPassword(code);
        user.save().then(function(user) {
          emailCode(email, code, response);
        }, function(error) {
          response.error("Failed to send code")
        });
      }
      else {
        response.error("User not found");
      }
    },
    error: function(error) {
      handleError(error, response)
    }
  });
})

Parse.Cloud.define("signup", function(request, response) {
  // EMAIL = USERNAME
  var email = request.params.email;
  var name = request.params.displayName;
  var code = randomCode()

  var emailQuery = new Parse.Query(Parse.User);
  emailQuery.equalTo("email", email);
  emailQuery.find({
    success: function(results) {
      if (results.length) {
        response.error("Email taken");
      }
      else {
        Parse.User.signUp(email, code,
         { email: email,
           code: code,
           name: name}, {
          success: function(user) {
            emailCode(email, code, response);
          },
          error: function(user, error) {
            response.error("Signup failed");
          }
        });
      }
    },
    error: function(error) {
      handleError(error, response)
    }
  });

});
