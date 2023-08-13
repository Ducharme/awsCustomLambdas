// Format 1.0 https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-develop-integrations-lambda.html

exports.handler = async function(event, context) {
  try {
    var mode = event.mode;
    if (mode == undefined) {
      if (event.body != undefined && event.body.length > 0) {
        var decoded = atob(event.body); // Base64
        if (decoded != undefined) {
          var parsed = JSON.parse(decoded);
          mode = parsed.mode;
        }
      }
    }

    console.log("Hello, World! mode=" + mode);
    return {
      statusCode: 200,
      body: JSON.stringify("Hello from Lambda! mode=" + mode)
    };
  } catch (error) {
    console.error("An hello occurred:", error);
    return {
      statusCode: 500,
      body: JSON.stringify("Internal Server Hello")
    };
  }
}
