var Mailgun = require('mailgun');
Mailgun.initialize('taptone.me', 'key-9jagq65bowrwiamosv35pcxj9lxt4q74');

Parse.Cloud.define("signup", function(request, response) {
  var email = request.params.email;

  var nums = [];
  for (i = 0; i < 6; i++) {
    nums.push(Math.floor((Math.random() * 10)));
  }
  var code = nums.join("");

  Parse.Cloud.useMasterKey();
  var query = new Parse.Query(Parse.User);
  query.equalTo("email", email);
  query.find({
    success: function(results) {
      if (results.length) {
        var user = results[0];
        user.setPassword(code);
        user.set("code", code);
        user.save();
      }
      else {
        Parse.User.signUp(email, code,
          { email: email,
            code: code }, {
          success: function(user) {
            console.log("User created");
          },
          error: function(user, error) {
            console.error(error);
            response.error("Failed to create user");
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
      subject: "Sign in code: "+code,
      text: "You requested a sign in code for Taptone."
  }, {
      success: function(httpResponse) {
            console.log(httpResponse);
                response.success("Email sent!");
                  },
      error: function(httpResponse) {
            console.error(httpResponse);
                response.error("Uh oh, something went wrong");
                  }
  });
});
