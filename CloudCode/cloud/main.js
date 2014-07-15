var Mailgun = require('mailgun');
Mailgun.initialize('taptone.me', 'key-9jagq65bowrwiamosv35pcxj9lxt4q74');

function randomCode() {
  var nums = [];
  for (i = 0; i < 6; i++) {
    nums.push(Math.floor((Math.random() * 10)));
  }
  return nums.join("");
}

Parse.Cloud.define("signup", function(request, response) {
  var email = request.params.email;
  var username = request.params.username;
  var code = randomCode()

  var emailQuery = new Parse.Query(Parse.User);
  emailQuery.equalTo("email", email);
  var usernameQuery = new Parse.Query(Parse.User);
  usernameQuery.equalTo("username", username);
  var query = Parse.Query.or(emailQuery, usernameQuery);
  query.find({
    success: function(results) {
      if (results.length) {
        var user = results[0];
        if (user.username == username) {
          response.error("Username taken");
        }
        else {
          response.error("Email taken");
        }
      }
      else {
        Parse.User.signUp(username, code,
         { email: email,
            code: code }, {
          success: function(user) {
            console.log("signup_succeeded");
          },
          error: function(user, error) {
            console.error(error);
            response.error("Signup failed");
          }
        });
      }
    },
    error: function(error) {
      if (error.code === Parse.Error.OBJECT_NOT_FOUND) {
      } else if (error.code === Parse.Error.CONNECTION_FAILED) {
        response.error("Connection error")
      }
    }
  });

  Mailgun.sendEmail({
      to: request.params.email,
      from: "taptone@taptone.me",
      subject: "Your sign in code: "+code,
      text: "You requested a sign in code for Taptone."
  }, {
      success: function(httpResponse) {
            console.log(httpResponse);
            response.success("Email sent");
                  },
      error: function(httpResponse) {
            console.error(httpResponse);
                response.error("Email code failed");
                  }
  });
  response.success("Sent verification email");
});
